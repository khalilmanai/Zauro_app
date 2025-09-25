import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter;

  constructor(private configService: ConfigService) {
    this.transporter = nodemailer.createTransport({
      host: this.configService.get<string>('smtp.host'),
      port: this.configService.get<number>('smtp.port'),
      secure: false, // true for 465, false for other ports
      auth: {
        user: this.configService.get<string>('smtp.user'),
        pass: this.configService.get<string>('smtp.pass'),
      },
    });
  }

  async sendPasswordResetOtp(email: string, otp: string): Promise<void> {
    const mailOptions = {
      from: this.configService.get<string>('smtp.from'),
      to: email,
      subject: 'Zauro - Password Reset OTP',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Password Reset Request</h2>
          <p>You have requested to reset your password for your Zauro account.</p>
          <p>Your OTP code is: <strong style="font-size: 24px; color: #007bff;">${otp}</strong></p>
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this password reset, please ignore this email.</p>
          <hr style="margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
        </div>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      this.logger.log(`Password reset OTP sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send password reset OTP to ${email}:`, error);
      throw error;
    }
  }

  async sendWelcomeEmail(email: string, firstName: string): Promise<void> {
    const mailOptions = {
      from: this.configService.get<string>('smtp.from'),
      to: email,
      subject: 'Welcome to Zauro Marketplace!',
      html: `
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
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      this.logger.log(`Welcome email sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send welcome email to ${email}:`, error);
      throw error;
    }
  }

  async sendTradeNotification(email: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void> {
    const mailOptions = {
      from: this.configService.get<string>('smtp.from'),
      to: email,
      subject: `Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'} - ${animalName}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #333;">Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'}!</h2>
          <p>Your animal "${animalName}" has been ${tradeType === 'sold' ? 'successfully sold' : 'purchased'} on the Zauro marketplace.</p>
          <p>Transaction details will be available in your wallet.</p>
          <hr style="margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
        </div>
      `,
    };

    try {
      await this.transporter.sendMail(mailOptions);
      this.logger.log(`Trade notification sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send trade notification to ${email}:`, error);
      throw error;
    }
  }
}
