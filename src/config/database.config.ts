import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';

export const createPrismaClient = (configService: ConfigService): PrismaClient => {
  return new PrismaClient({
    datasources: {
      db: {
        url: configService.get<string>('database.url'),
      },
    },
    log: configService.get('nodeEnv') === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
  });
};
