import { Module } from '@nestjs/common';
import { DidService } from './did.service';
import { CredentialsService } from './credentials.service';
import { DidController } from './did.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { WalletModule } from '../wallet/wallet.module';

@Module({
  imports: [PrismaModule, WalletModule],
  controllers: [DidController],
  providers: [DidService, CredentialsService],
  exports: [DidService, CredentialsService],
})
export class DidModule {}
