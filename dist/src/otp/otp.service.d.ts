import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { OtpType } from '@prisma/client';
export declare class OtpService {
    private prisma;
    private configService;
    constructor(prisma: PrismaService, configService: ConfigService);
    generateOtp(userId: string, type: OtpType): Promise<{
        code: string;
    }>;
    verifyOtp(userId: string, code: string, type: OtpType): Promise<boolean>;
    invalidateOtp(userId: string, code: string): Promise<void>;
    cleanupExpiredOtps(): Promise<void>;
}
