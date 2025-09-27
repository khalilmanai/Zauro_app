import { ConfigService } from '@nestjs/config';
export declare class MailService {
    private configService;
    private readonly logger;
    private transporter;
    private fromAddress;
    constructor(configService: ConfigService);
    sendMail(to: string, subject: string, text: string, html?: string): Promise<boolean>;
    sendPasswordResetOtp(email: string, otp: string): Promise<void>;
    sendWelcomeEmail(email: string, firstName: string): Promise<void>;
    sendTradeNotification(email: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void>;
}
