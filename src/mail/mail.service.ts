import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { Transporter } from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: Transporter;
  private fromAddress: string;

  constructor(private configService: ConfigService) {
    const smtpHost = this.configService.get<string>('smtp.host');
    const smtpPort = this.configService.get<number>('smtp.port');
    const smtpSecure = this.configService.get<boolean>('smtp.secure');
    const smtpUser = this.configService.get<string>('smtp.user');
    const smtpPass = this.configService.get<string>('smtp.pass');
    this.fromAddress = this.configService.get<string>('smtp.from') || 'noreply@zauro.com';

    if (!smtpHost || !smtpUser || !smtpPass) {
      throw new Error('SMTP configuration (SMTP_HOST, SMTP_USER, SMTP_PASS) must be configured in environment variables');
    }

    this.transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpSecure, // true for 465, false for other ports
      auth: {
        user: smtpUser,
        pass: smtpPass,
      },
    });

    // Verify SMTP connection configuration
    this.transporter.verify((error, success) => {
      if (error) {
        this.logger.error('SMTP configuration error:', error);
      } else {
        this.logger.log('SMTP server is ready to take messages');
      }
    });
  }

  /**
   * Generic method to send emails via SMTP
   * @param to Recipient email address
   * @param subject Email subject
   * @param text Plain text content
   * @param html HTML content (optional)
   * @returns Promise<boolean> - true if sent successfully, false otherwise
   */
  async sendMail(to: string, subject: string, text: string, html?: string): Promise<boolean> {
    try {
      const mailOptions = {
        from: this.fromAddress,
        to,
        subject,
        text,
        ...(html && { html }),
      };

      const info = await this.transporter.sendMail(mailOptions);
      this.logger.log(`Email sent successfully to ${to}. MessageId: ${info.messageId}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send email to ${to}:`, error);
      return false;
    }
  }

  async sendPasswordResetOtp(email: string, otp: string): Promise<void> {
    const subject = 'Zauro - Password Reset OTP';
    const text = `Password Reset Request

You have requested to reset your password for your Zauro account.
Your OTP code is: ${otp}
This code will expire in 10 minutes.

If you didn't request this password reset, please ignore this email.

This is an automated message from Zauro Marketplace.`;

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Password Reset Request</h2>
        <p>You have requested to reset your password for your Zauro account.</p>
        <p>Your OTP code is: <strong style="font-size: 24px; color: #007bff;">${otp}</strong></p>
        <p>This code will expire in 10 minutes.</p>
        <p>If you didn't request this password reset, please ignore this email.</p>
        <hr style="margin: 20px 0;">
        <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
      </div>
    `;

    const success = await this.sendMail(email, subject, text, html);
    if (!success) {
      throw new Error(`Failed to send password reset OTP to ${email}`);
    }
  }

  async sendWelcomeEmail(email: string, firstName: string): Promise<void> {
    const subject = 'Welcome to Zauro Marketplace!';
    const text = `Welcome to Zauro, ${firstName}!

Thank you for joining the Zauro blockchain-based animal marketplace.

You can now:
- Create and manage your animal NFTs
- Trade animals on our marketplace
- Access your Hedera wallet

Happy trading!

This is an automated message from Zauro Marketplace.`;

    const html = `
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
    `;

    const success = await this.sendMail(email, subject, text, html);
    if (!success) {
      throw new Error(`Failed to send welcome email to ${email}`);
    }
  }

  async sendTradeNotification(email: string, tradeType: 'sold' | 'purchased', animalName: string): Promise<void> {
    const subject = `Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'} - ${animalName}`;
    const text = `Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'}!

Your animal "${animalName}" has been ${tradeType === 'sold' ? 'successfully sold' : 'purchased'} on the Zauro marketplace.
Transaction details will be available in your wallet.

This is an automated message from Zauro Marketplace.`;

    const html = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Animal ${tradeType === 'sold' ? 'Sold' : 'Purchased'}!</h2>
        <p>Your animal "${animalName}" has been ${tradeType === 'sold' ? 'successfully sold' : 'purchased'} on the Zauro marketplace.</p>
        <p>Transaction details will be available in your wallet.</p>
        <hr style="margin: 20px 0;">
        <p style="color: #666; font-size: 12px;">This is an automated message from Zauro Marketplace.</p>
      </div>
    `;

    const success = await this.sendMail(email, subject, text, html);
    if (!success) {
      throw new Error(`Failed to send trade notification to ${email}`);
    }
  }
}