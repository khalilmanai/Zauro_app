"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var MailService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MailService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const mailersend_1 = require("mailersend");
let MailService = MailService_1 = class MailService {
    configService;
    logger = new common_1.Logger(MailService_1.name);
    mailerSend;
    constructor(configService) {
        this.configService = configService;
        const apiKey = this.configService.get('mailersend.apiKey');
        const fromEmail = this.configService.get('mailersend.from');
        if (!apiKey) {
            throw new Error('MailerSend API key (MAILERSEND_API_KEY) must be configured in environment variables');
        }
        if (!fromEmail) {
            throw new Error('MailerSend from email (MAILERSEND_FROM) must be configured in environment variables');
        }
        this.mailerSend = new mailersend_1.MailerSend({
            apiKey: apiKey,
        });
    }
    async sendPasswordResetOtp(email, otp) {
        const sentFrom = new mailersend_1.Sender(this.configService.get('mailersend.from'), 'Zauro Marketplace');
        const recipients = [new mailersend_1.Recipient(email, 'User')];
        const emailParams = new mailersend_1.EmailParams()
            .setFrom(sentFrom)
            .setTo(recipients)
            .setSubject('Zauro - Password Reset OTP')
            .setHtml(`
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Password Reset Request</h2>
          <p>You have requested to reset your password for your Zauro account.</p>
          <p>Your OTP code is: <strong style="font-size: 24px; color: #007bff;">${otp}</strong></p>
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this password reset, please ignore this email.</p>
          <hr style="margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
        </div>
      `)
            .setText(`Password Reset Request

You have requested to reset your password for your Zauro account.
Your OTP code is: ${otp}
This code will expire in 10 minutes.

If you didn't request this password reset, please ignore this email.

This is an automated message from Zauro Marketplace.`);
        try {
            await this.mailerSend.email.send(emailParams);
            this.logger.log(`Password reset OTP sent to ${email}`);
        }
        catch (error) {
            this.logger.error(`Failed to send password reset OTP to ${email}:`, error);
            throw error;
        }
    }
    async sendWelcomeEmail(email, firstName) {
        const sentFrom = new mailersend_1.Sender(this.configService.get('mailersend.from'), 'Zauro Marketplace');
        const recipients = [new mailersend_1.Recipient(email, firstName)];
        const emailParams = new mailersend_1.EmailParams()
            .setFrom(sentFrom)
            .setTo(recipients)
            .setSubject('Welcome to Zauro Marketplace!')
            .setHtml(`
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Welcome to Zauro, ${firstName}!</h2>
          <p>Thank you for joining the Zauro blockchain-based animal marketplace.</p>
          <p>You can now:</p>
          <ul>
            <li>Create and manage your animal NFTs</li>
            <li>Trade animals on our marketplace</li>
            <li>Access your Hedera wallet</li>
          </ul>
          <p>Happy trading!</p>
          <hr style="margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
        </div>
      `)
            .setText(`Welcome to Zauro, ${firstName}!

Thank you for joining the Zauro blockchain-based animal marketplace.

You can now:
- Create and manage your animal NFTs
- Trade animals on our marketplace
- Access your Hedera wallet

Happy trading!

This is an automated message from Zauro Marketplace.`);
        try {
            await this.mailerSend.email.send(emailParams);
            this.logger.log(`Welcome email sent to ${email}`);
        }
        catch (error) {
            this.logger.error(`Failed to send welcome email to ${email}:`, error);
            throw error;
        }
    }
    async sendTradeNotification(email, tradeType, animalName) {
        const sentFrom = new mailersend_1.Sender(this.configService.get('mailersend.from'), 'Zauro Marketplace');
        const recipients = [new mailersend_1.Recipient(email, 'User')];
        const emailParams = new mailersend_1.EmailParams()
            .setFrom(sentFrom)
            .setTo(recipients)
            .setSubject(`Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'} - ${animalName}`)
            .setHtml(`
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'}!</h2>
          <p>Your animal "${animalName}" has been ${tradeType === 'sold' ? 'successfully sold' : 'purchased'} on the Zauro marketplace.</p>
          <p>Transaction details will be available in your wallet.</p>
          <hr style="margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
        </div>
      `)
            .setText(`Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'}!

Your animal "${animalName}" has been ${tradeType === 'sold' ? 'successfully sold' : 'purchased'} on the Zauro marketplace.
Transaction details will be available in your wallet.

This is an automated message from Zauro Marketplace.`);
        try {
            await this.mailerSend.email.send(emailParams);
            this.logger.log(`Trade notification sent to ${email}`);
        }
        catch (error) {
            this.logger.error(`Failed to send trade notification to ${email}:`, error);
            throw error;
        }
    }
};
exports.MailService = MailService;
exports.MailService = MailService = MailService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], MailService);
//# sourceMappingURL=mail.service.js.map