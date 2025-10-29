import { Injectable, NotFoundException, ForbiddenException, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from '../supabase/supabase.service';
import { HederaService } from '../wallet/services/hedera.service';
import { EncryptionService } from '../wallet/services/encryption.service';
import { CollectionsService } from '../collections/collections.service';
import { AIAnalysisService, VetInfo } from './ai-analysis.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { AnimalResponseDto } from './dto/animal-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { AnimalSpecies } from '@prisma/client';
import { createAnimalNftMetadata } from '../common/utils/nft-metadata.util';

@Injectable()
export class AnimalsService {
  constructor(
    private prisma: PrismaService,
    @Inject(forwardRef(() => SupabaseService))
    private supabaseService: SupabaseService,
    private hederaService: HederaService,
    private encryptionService: EncryptionService,
    private collectionsService: CollectionsService,
    private aiAnalysisService: AIAnalysisService,
    private configService: ConfigService,
  ) {}

  async createAnimal(
    createAnimalDto: CreateAnimalDto,
    userId: string,
    imageFile?: Express.Multer.File,
    vetRecordFile?: Express.Multer.File,
    enableAIAnalysis: boolean = true,
  ): Promise<AnimalResponseDto> {
    let imageUrl: string | undefined;
    let vetRecordUrl: string | undefined;

    // Upload files if provided
    if (imageFile) {
      const imageResult = await this.supabaseService.uploadAnimalImage(imageFile, userId);
      imageUrl = imageResult.url;
    }

    if (vetRecordFile) {
      const vetResult = await this.supabaseService.uploadVetRecord(vetRecordFile, userId);
      vetRecordUrl = vetResult.url;
    }

    // AI Analysis if enabled and image is available
    let aiPredictionValue: number | undefined;
    let aiAnalysisData: any = null;

    if (enableAIAnalysis && imageUrl && createAnimalDto.species === 'COW') {
      try {
        // Optional: Extract vet info from vet record
        const vetInfo: VetInfo | undefined = undefined; // Could parse vetRecordUrl here
        
        // Perform AI analysis
        const aiResult = await this.aiAnalysisService.analyzeAnimal(
          imageUrl,
          undefined, // Will be assigned after creation
          vetInfo,
        );

        // Store AI analysis data for reference
        aiAnalysisData = {
          detected_attributes: aiResult.detected_attributes,
          ai_confidence: aiResult.ai_confidence,
        };

        // If breed/age detected but not provided, update from AI
        if (!createAnimalDto.breed && aiResult.detected_attributes.breed) {
          createAnimalDto.breed = aiResult.detected_attributes.breed;
        }

        // If age not provided but AI detected it
        if (!createAnimalDto.age && aiResult.detected_attributes.age) {
          const parsedAge = this.aiAnalysisService.parseAge(aiResult.detected_attributes.age);
          if (parsedAge !== undefined) {
            createAnimalDto.age = parsedAge;
          }
        }

        // Predict market value
        const priceResult = await this.aiAnalysisService.predictMarketValue(
          imageUrl,
          undefined,
          vetInfo,
        );
        
        // Extract numeric value from price string
        const priceMatch = priceResult.predicted_market_price?.match(/(\d+\.?\d*)/);
        if (priceMatch) {
          aiPredictionValue = parseFloat(priceMatch[1]);
        }
      } catch (error) {
        console.error('AI Analysis failed, continuing without AI data:', error);
        // Continue without AI analysis if it fails
      }
    }

    // Create animal record
    const animal = await this.prisma.animal.create({
      data: {
        ...createAnimalDto,
        ownerId: userId,
        imageUrl,
        vetRecordUrl,
        aiPredictionValue,
      },
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    // IMPORTANT: NFT minting is now only done after expert approval
    // Animals are created with status PENDING_EXPERT_REVIEW
    // See mintAnimal() method for minting after expert approval
    
    console.log('Animal created with status PENDING_EXPERT_REVIEW. NFT will be minted after expert approval.');

    return animal;
  }

  /**
   * Mint NFT after expert approval
   * This is called after an expert approves the animal
   */
  async mintAnimal(id: string, userId: string): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== userId) {
      throw new ForbiddenException('You can only mint your own animals');
    }

    if (animal.status !== 'EXPERT_APPROVED') {
      throw new BadRequestException('Animal must be approved by an expert before minting');
    }

    if (animal.tokenId && animal.tokenSerialNumber) {
      throw new BadRequestException('NFT already minted for this animal');
    }

    try {
      const wallet = await this.prisma.wallet.findUnique({
        where: { userId },
      });

      if (!wallet) {
        throw new BadRequestException('Wallet not found. Please create a wallet first.');
      }

      const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
      
      // Get or create collection with capacity check
      const collection = await this.collectionsService.getOrRotateDefaultForMint({
        namePrefix: 'Animals',
        symbolPrefix: 'ANML',
        memo: 'Animal NFT collection',
      });
      
      // Create NFT metadata (Hedera has 100 byte limit)
      const metadata = createAnimalNftMetadata(
        animal.name,
        animal.species,
        animal.breed,
        animal.age,
        animal.id
      );

      // Mint NFT using the collection token ID and transfer to user's wallet
      console.log(`Minting NFT for user wallet: ${wallet.hederaAccountId}`);
      const nftResult = await this.hederaService.mintNft(
        collection.tokenId,
        metadata,
        this.configService.get<string>('hedera.privateKey') || '',
        wallet.hederaAccountId,
        privateKey
      );

      // Update animal with NFT details and mark as MINTED
      const updatedAnimal = await this.prisma.animal.update({
        where: { id: animal.id },
        data: {
          tokenId: collection.tokenId,
          tokenSerialNumber: nftResult.serialNumber,
          status: 'MINTED',
        },
        include: {
          owner: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
      });

      return updatedAnimal;
    } catch (error) {
      console.error('NFT minting failed:', error);
      throw new BadRequestException(`Failed to mint NFT: ${error.message}`);
    }
  }

  /**
   * Expert reviews an animal - approves or rejects
   * Only accessible by ADMIN or HR_MANAGER
   */
  async reviewAnimal(
    id: string,
    userId: string,
    approved: boolean,
    comment?: string,
  ): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.status !== 'PENDING_EXPERT_REVIEW') {
      throw new BadRequestException('Animal is not pending review');
    }

    // Check user role
    const reviewer = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (!reviewer || (reviewer.role !== 'ADMIN' && reviewer.role !== 'HR_MANAGER')) {
      throw new ForbiddenException('Only admins and managers can review animals');
    }

    const status = approved ? 'EXPERT_APPROVED' : 'EXPERT_REJECTED';
    const updatedAnimal = await this.prisma.animal.update({
      where: { id },
      data: {
        status,
        expertReviewedBy: userId,
        expertReviewComment: comment,
        expertReviewDate: new Date(),
      },
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    return updatedAnimal;
  }

  /**
   * Get animals pending expert review
   */
  async getPendingReviewAnimals(paginationDto: PaginationDto): Promise<{
    animals: AnimalResponseDto[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { page = 1, limit = 10 } = paginationDto;
    const skip = (page - 1) * limit;

    const [animals, total] = await Promise.all([
      this.prisma.animal.findMany({
        where: { status: 'PENDING_EXPERT_REVIEW' },
        skip,
        take: limit,
        include: {
          owner: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.animal.count({ where: { status: 'PENDING_EXPERT_REVIEW' } }),
    ]);

    return {
      animals,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findAll(paginationDto: PaginationDto): Promise<{
    animals: AnimalResponseDto[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { page = 1, limit = 10 } = paginationDto;
    const skip = (page - 1) * limit;



    const [animals, total] = await Promise.all([
      this.prisma.animal.findMany({
        skip,
        take: limit,
        include: {
          owner: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.animal.count(),
    ]);

    return {
      animals,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findAllByOwnerId(paginationDto: PaginationDto, ownerId: string): Promise<{
    animals: AnimalResponseDto[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { page = 1, limit = 10 } = paginationDto;
    const skip = (page - 1) * limit;


    const [animals, total] = await Promise.all([
      this.prisma.animal.findMany({
        where: { ownerId },
        skip,
        take: limit,
        include: {
          owner: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.animal.count({ where: { ownerId } }),
    ]);

    return {
      animals,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    return animal;
  }

  async update(id: string, updateAnimalDto: UpdateAnimalDto, userId: string): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own animals');
    }

    const updatedAnimal = await this.prisma.animal.update({
      where: { id },
      data: updateAnimalDto,
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    return updatedAnimal;
  }

  async remove(id: string, userId: string): Promise<{ message: string }> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== userId) {
      throw new ForbiddenException('You can only delete your own animals');
    }

    // Check if animal is listed for trade
    const activeTrade = await this.prisma.trade.findFirst({
      where: {
        animalId: id,
        status: {
          in: ['PENDING', 'LISTED', 'IN_PROGRESS'],
        },
      },
    });

    if (activeTrade) {
      throw new BadRequestException('Cannot delete animal that is currently listed for trade');
    }

    // Burn NFT if it exists
    if (animal.tokenId && animal.tokenSerialNumber) {
      try {
        const wallet = await this.prisma.wallet.findUnique({
          where: { userId },
        });

        if (wallet) {
          const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
          await this.hederaService.burnNft(animal.tokenId, animal.tokenSerialNumber, privateKey);
        }
      } catch (error) {
        console.error('NFT burning failed:', error);
      }
    }

    // Delete animal record
    await this.prisma.animal.delete({
      where: { id },
    });

    return { message: 'Animal deleted successfully' };
  }

  async uploadAnimalImage(id: string, userId: string, imageFile: Express.Multer.File): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own animals');
    }

    // Upload new image
    const imageResult = await this.supabaseService.uploadAnimalImage(imageFile, userId);

    // Update animal with new image URL
    const updatedAnimal = await this.prisma.animal.update({
      where: { id },
      data: { imageUrl: imageResult.url },
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    return updatedAnimal;
  }

  async uploadVetRecord(id: string, userId: string, vetRecordFile: Express.Multer.File): Promise<AnimalResponseDto> {
    const animal = await this.prisma.animal.findUnique({
      where: { id },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own animals');
    }

    // Upload vet record
    const vetResult = await this.supabaseService.uploadVetRecord(vetRecordFile, userId);

    // Update animal with new vet record URL
    const updatedAnimal = await this.prisma.animal.update({
      where: { id },
      data: { vetRecordUrl: vetResult.url },
      include: {
        owner: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });

    return updatedAnimal;
  }
}
