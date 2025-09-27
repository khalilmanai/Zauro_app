import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from '../supabase/supabase.service';
import { HederaService } from '../wallet/services/hedera.service';
import { EncryptionService } from '../wallet/services/encryption.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { AnimalResponseDto } from './dto/animal-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { AnimalSpecies } from '@prisma/client';

@Injectable()
export class AnimalsService {
  constructor(
    private prisma: PrismaService,
    private supabaseService: SupabaseService,
    private hederaService: HederaService,
    private encryptionService: EncryptionService,
  ) {}

  async createAnimal(
    createAnimalDto: CreateAnimalDto,
    userId: string,
    imageFile?: Express.Multer.File,
    vetRecordFile?: Express.Multer.File,
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

    // Create animal record
    const animal = await this.prisma.animal.create({
      data: {
        ...createAnimalDto,
        ownerId: userId,
        imageUrl,
        vetRecordUrl,
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

    // Mint NFT on Hedera
    try {
      const wallet = await this.prisma.wallet.findUnique({
        where: { userId },
      });

      if (wallet) {
        const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
        
        // Create NFT metadata
        const metadata = JSON.stringify({
          name: animal.name,
          species: animal.species,
          breed: animal.breed,
          age: animal.age,
          description: animal.description,
          image: imageUrl,
          vetRecord: vetRecordUrl,
          aiPredictionValue: animal.aiPredictionValue,
        });

        // Mint NFT (using a mock token ID for now)
        const tokenId = '0.0.123456'; // Replace with actual animal NFT token ID
        const nftResult = await this.hederaService.mintNft(tokenId, metadata, wallet.hederaAccountId, privateKey);

        // Update animal with NFT details
        const updatedAnimal = await this.prisma.animal.update({
          where: { id: animal.id },
          data: {
            tokenId,
            tokenSerialNumber: nftResult.serialNumber,
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
    } catch (error) {
      // If NFT minting fails, we still keep the animal record
      console.error('NFT minting failed:', error);
    }

    return animal;
  }

  async findAll(paginationDto: PaginationDto, ownerId?: string): Promise<{
    animals: AnimalResponseDto[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
    const { page = 1, limit = 10 } = paginationDto;
    const skip = (page - 1) * limit;

    const where = ownerId ? { ownerId } : {};

    const [animals, total] = await Promise.all([
      this.prisma.animal.findMany({
        where,
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
      this.prisma.animal.count({ where }),
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
          await this.hederaService.burnNft(animal.tokenId, animal.tokenSerialNumber);
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
