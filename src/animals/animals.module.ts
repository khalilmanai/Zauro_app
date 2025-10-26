import { Module } from '@nestjs/common';
import { AnimalsService } from './animals.service';
import { AnimalsController } from './animals.controller';
import { AIAnalysisService } from './ai-analysis.service';
import { PrismaModule } from '../prisma/prisma.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { WalletModule } from '../wallet/wallet.module';
import { CollectionsModule } from '../collections/collections.module';

@Module({
  imports: [PrismaModule, SupabaseModule, WalletModule, CollectionsModule],
  controllers: [AnimalsController],
  providers: [AnimalsService, AIAnalysisService],
  exports: [AnimalsService, AIAnalysisService],
})
export class AnimalsModule {}
