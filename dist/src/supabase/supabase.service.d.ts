import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
export declare class SupabaseService {
    private configService;
    private prisma;
    private readonly logger;
    private supabase;
    constructor(configService: ConfigService, prisma: PrismaService);
    uploadFile(file: Express.Multer.File, bucket: string, userId: string): Promise<{
        url: string;
        path: string;
    }>;
    uploadAnimalImage(file: Express.Multer.File, userId: string): Promise<{
        url: string;
        path: string;
    }>;
    uploadVetRecord(file: Express.Multer.File, userId: string): Promise<{
        url: string;
        path: string;
    }>;
    deleteFile(bucket: string, path: string): Promise<void>;
    getFileUrl(bucket: string, path: string): Promise<string>;
    createSignedUrl(bucket: string, path: string, expiresIn?: number): Promise<string>;
}
