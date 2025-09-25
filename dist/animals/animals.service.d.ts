import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from '../supabase/supabase.service';
import { HederaService } from '../wallet/services/hedera.service';
import { EncryptionService } from '../wallet/services/encryption.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { AnimalResponseDto } from './dto/animal-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
export declare class AnimalsService {
    private prisma;
    private supabaseService;
    private hederaService;
    private encryptionService;
    constructor(prisma: PrismaService, supabaseService: SupabaseService, hederaService: HederaService, encryptionService: EncryptionService);
    createAnimal(createAnimalDto: CreateAnimalDto, userId: string, imageFile?: Express.Multer.File, vetRecordFile?: Express.Multer.File): Promise<AnimalResponseDto>;
    findAll(paginationDto: PaginationDto, ownerId?: string): Promise<{
        animals: AnimalResponseDto[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    findOne(id: string): Promise<AnimalResponseDto>;
    update(id: string, updateAnimalDto: UpdateAnimalDto, userId: string): Promise<AnimalResponseDto>;
    remove(id: string, userId: string): Promise<{
        message: string;
    }>;
    uploadAnimalImage(id: string, userId: string, imageFile: Express.Multer.File): Promise<AnimalResponseDto>;
    uploadVetRecord(id: string, userId: string, vetRecordFile: Express.Multer.File): Promise<AnimalResponseDto>;
}
