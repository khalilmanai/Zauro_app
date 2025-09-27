import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { MailerSend, EmailParams, Sender, Recipient } from 'mailersend';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private mailerSend: MailerSend;

  constructor(private configService: ConfigService) {
    const apiKey = this.configService.get<string>('mailersend.apiKey');
    const fromEmail = this.configService.get<string>('mailersend.from');

    if (!apiKey) {
      throw new Error('MailerSend API key (MAILERSEND_API_KEY) must be configured in environment variables');
    }

    if (!fromEmail) {
      throw new Error('MailerSend from email (MAILERSEND_FROM) must be configured in environment variables');
    }

    this.mailerSend = new MailerSend({
      apiKey: apiKey,
    });
  }

  async sendPasswordResetOtp(email: string, otp: string): Promise<void> {
    const sentFrom = new Sender(this.configService.get<string>('mailersend.from')!, 'Zauro Marketplace');
    const recipients = [new Recipient(email, 'User')];

    const emailParams = new EmailParams()
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
    } catch (error) {
      this.logger.error(`Failed to send password reset OTP to ${email}:`, error);
      throw error;
    }
  }

  async sendWelcomeEmail(email: string, firstName: string): Promise<void> {
    const sentFrom = new Sender(this.configService.get<string>('mailersend.from')!, 'Zauro Marketplace');
    const recipients = [new Recipient(email, firstName)];

    const emailParams = new EmailParams()
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
    } catch (error) {
      this.logger.error(`Failed to send welcome email to ${email}:`, error);
      throw error;
    }
  }

  async sendTradeNotification(email: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void> {
    const sentFrom = new Sender(this.configService.get<string>('mailersend.from')!, 'Zauro Marketplace');
    const recipients = [new Recipient(email, 'User')];

    const emailParams = new EmailParams()
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
    } catch (error) {
      this.logger.error(`Failed to send trade notification to ${email}:`, error);
      throw error;
    }
  }
}