import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { OtpModule } from './otp/otp.module';
import { MailModule } from './mail/mail.module';
import { SmsModule } from './sms/sms.module';
import { WalletModule } from './wallet/wallet.module';
import { AnimalsModule } from './animals/animals.module';
import { TradesModule } from './trades/trades.module';
import { SupabaseModule } from './supabase/supabase.module';
import { CollectionsModule } from './collections/collections.module';
import { DidModule } from './did/did.module';
import configuration from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60,
        limit: 10,
      },
    ]),
    PrismaModule,
    AuthModule,
    OtpModule,
    MailModule,
    SmsModule,
    WalletModule,
    AnimalsModule,
    TradesModule,
    SupabaseModule,
    CollectionsModule,
    DidModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
