import { ConfigService } from '@nestjs/config';
export declare class SmsService {
    private configService;
    private readonly logger;
    private client;
    constructor(configService: ConfigService);
    sendPasswordResetOtp(phone: string, otp: string): Promise<void>;
    sendWelcomeSms(phone: string, firstName: string): Promise<void>;
    sendTradeNotification(phone: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void>;
}
