import { Module } from '@nestjs/common';
import { SupabaseService } from './supabase.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [SupabaseService],
  exports: [SupabaseService],
})
export class SupabaseModule {}
