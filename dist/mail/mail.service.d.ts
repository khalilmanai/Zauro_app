import { ConfigService } from '@nestjs/config';
export declare class MailService {
    private configService;
    private readonly logger;
    private transporter;
    constructor(configService: ConfigService);
    sendPasswordResetOtp(email: string, otp: string): Promise<void>;
    sendWelcomeEmail(email: string, firstName: string): Promise<void>;
    sendTradeNotification(email: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void>;
}
