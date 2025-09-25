"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var MailService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.MailService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const nodemailer = __importStar(require("nodemailer"));
let MailService = MailService_1 = class MailService {
    configService;
    logger = new common_1.Logger(MailService_1.name);
    transporter;
    constructor(configService) {
        this.configService = configService;
        this.transporter = nodemailer.createTransport({
            host: this.configService.get('smtp.host'),
            port: this.configService.get('smtp.port'),
            secure: false,
            auth: {
                user: this.configService.get('smtp.user'),
                pass: this.configService.get('smtp.pass'),
            },
        });
    }
    async sendPasswordResetOtp(email, otp) {
        const mailOptions = {
            from: this.configService.get('smtp.from'),
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
        }
        catch (error) {
            this.logger.error(`Failed to send password reset OTP to ${email}:`, error);
            throw error;
        }
    }
    async sendWelcomeEmail(email, firstName) {
        const mailOptions = {
            from: this.configService.get('smtp.from'),
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
        }
        catch (error) {
            this.logger.error(`Failed to send welcome email to ${email}:`, error);
            throw error;
        }
    }
    async sendTradeNotification(email, tradeType, animalName) {
        const mailOptions = {
            from: this.configService.get('smtp.from'),
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