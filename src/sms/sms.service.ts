import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import twilio from 'twilio';

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);
  private client: twilio.Twilio;

  constructor(private configService: ConfigService) {
    this.client = twilio(
      this.configService.get<string>('twilio.accountSid'),
      this.configService.get<string>('twilio.authToken'),
    );
  }

  async sendPasswordResetOtp(phone: string, otp: string): Promise<void> {
    const message = `Your Zauro password reset OTP is: ${otp}. This code expires in 10 minutes. Do not share this code with anyone.`;

    try {
      await this.client.messages.create({
        body: message,
        from: this.configService.get<string>('twilio.phoneNumber'),
        to: phone,
      });
      this.logger.log(`Password reset OTP sent to ${phone}`);
    } catch (error) {
      this.logger.error(`Failed to send password reset OTP to ${phone}:`, error);
      throw error;
    }
  }

  async sendWelcomeSms(phone: string, firstName: string): Promise<void> {
    const message = `Welcome to Zauro Marketplace, ${firstName}! You can now trade animals as NFTs on the blockchain. Happy trading!`;

    try {
      await this.client.messages.create({
        body: message,
        from: this.configService.get<string>('twilio.phoneNumber'),
        to: phone,
      });
      this.logger.log(`Welcome SMS sent to ${phone}`);
    } catch (error) {
      this.logger.error(`Failed to send welcome SMS to ${phone}:`, error);
      throw error;
    }
  }

  async sendTradeNotification(phone: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void> {
    const message = `Your animal "${animalName}" has been ${tradeType === 'sold' ? 'sold' : 'purchased'} on Zauro marketplace. Check your wallet for details.`;

    try {
      await this.client.messages.create({
        body: message,
        from: this.configService.get<string>('twilio.phoneNumber'),
        to: phone,
      });
      this.logger.log(`Trade notification SMS sent to ${phone}`);
    } catch (error) {
      this.logger.error(`Failed to send trade notification SMS to ${phone}:`, error);
      throw error;
    }
  }
}
