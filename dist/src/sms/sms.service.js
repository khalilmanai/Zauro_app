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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
var SmsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const twilio_1 = __importDefault(require("twilio"));
let SmsService = SmsService_1 = class SmsService {
    configService;
    logger = new common_1.Logger(SmsService_1.name);
    client;
    constructor(configService) {
        this.configService = configService;
        const accountSid = this.configService.get('twilio.accountSid');
        const authToken = this.configService.get('twilio.authToken');
        const phoneNumber = this.configService.get('twilio.phoneNumber');
        if (!accountSid || !authToken || !phoneNumber) {
            throw new Error('Twilio credentials (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER) must be configured in environment variables');
        }
        this.client = (0, twilio_1.default)(accountSid, authToken);
    }
    async sendPasswordResetOtp(phone, otp) {
        const message = `Your Zauro password reset OTP is: ${otp}. This code expires in 10 minutes. Do not share this code with anyone.`;
        try {
            await this.client.messages.create({
                body: message,
                from: this.configService.get('twilio.phoneNumber'),
                to: phone,
            });
            this.logger.log(`Password reset OTP sent to ${phone}`);
        }
        catch (error) {
            this.logger.error(`Failed to send password reset OTP to ${phone}:`, error);
            throw error;
        }
    }
    async sendWelcomeSms(phone, firstName) {
        const message = `Welcome to Zauro Marketplace, ${firstName}! You can now trade animals as NFTs on the blockchain. Happy trading!`;
        try {
            await this.client.messages.create({
                body: message,
                from: this.configService.get('twilio.phoneNumber'),
                to: phone,
            });
            this.logger.log(`Welcome SMS sent to ${phone}`);
        }
        catch (error) {
            this.logger.error(`Failed to send welcome SMS to ${phone}:`, error);
            throw error;
        }
    }
    async sendTradeNotification(phone, tradeType, animalName) {
        const message = `Your animal "${animalName}" has been ${tradeType === 'sold' ? 'sold' : 'purchased'} on Zauro marketplace. Check your wallet for details.`;
        try {
            await this.client.messages.create({
                body: message,
                from: this.configService.get('twilio.phoneNumber'),
                to: phone,
            });
            this.logger.log(`Trade notification SMS sent to ${phone}`);
        }
        catch (error) {
            this.logger.error(`Failed to send trade notification SMS to ${phone}:`, error);
            throw error;
        }
    }
};
exports.SmsService = SmsService;
exports.SmsService = SmsService = SmsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], SmsService);
//# sourceMappingURL=sms.service.js.map