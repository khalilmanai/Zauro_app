import { Module } from '@nestjs/common';
import { WalletService } from './wallet.service';
import { WalletController } from './wallet.controller';
import { HederaService } from './services/hedera.service';
import { EncryptionService } from './services/encryption.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [WalletController],
  providers: [WalletService, HederaService, EncryptionService],
  exports: [WalletService, HederaService, EncryptionService],
})
export class WalletModule {}
