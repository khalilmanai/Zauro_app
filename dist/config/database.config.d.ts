import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';
export declare const createPrismaClient: (configService: ConfigService) => PrismaClient;
