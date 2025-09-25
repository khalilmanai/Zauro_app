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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../prisma/prisma.service");
const bcrypt = __importStar(require("bcryptjs"));
const otp_service_1 = require("../otp/otp.service");
const mail_service_1 = require("../mail/mail.service");
const sms_service_1 = require("../sms/sms.service");
let AuthService = class AuthService {
    prisma;
    jwtService;
    configService;
    otpService;
    mailService;
    smsService;
    constructor(prisma, jwtService, configService, otpService, mailService, smsService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
        this.configService = configService;
        this.otpService = otpService;
        this.mailService = mailService;
        this.smsService = smsService;
    }
    async register(registerDto) {
        const { email, phone, password, firstName, lastName } = registerDto;
        const existingUser = await this.prisma.user.findFirst({
            where: {
                OR: [
                    { email },
                    ...(phone ? [{ phone }] : []),
                ],
            },
        });
        if (existingUser) {
            throw new common_1.ConflictException('User with this email or phone already exists');
        }
        const hashedPassword = await bcrypt.hash(password, 12);
        const user = await this.prisma.user.create({
            data: {
                email,
                phone,
                password: hashedPassword,
                firstName,
                lastName,
            },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                role: true,
                isVerified: true,
            },
        });
        const tokens = await this.generateTokens(user.id);
        return {
            ...tokens,
            user,
        };
    }
    async login(loginDto) {
        const { email, password } = loginDto;
        const user = await this.prisma.user.findUnique({
            where: { email },
        });
        if (!user || !user.isActive) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        await this.prisma.user.update({
            where: { id: user.id },
            data: { lastLoginAt: new Date() },
        });
        const tokens = await this.generateTokens(user.id);
        return {
            ...tokens,
            user: {
                id: user.id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                role: user.role,
                isVerified: user.isVerified,
            },
        };
    }
    async refreshToken(userId) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { id: true, isActive: true },
        });
        if (!user || !user.isActive) {
            throw new common_1.UnauthorizedException('Invalid refresh token');
        }
        const payload = { sub: userId };
        const accessToken = this.jwtService.sign(payload, {
            secret: this.configService.get('jwt.secret'),
            expiresIn: this.configService.get('jwt.expiresIn'),
        });
        return { accessToken };
    }
    async forgotPasswordRequest(email, phone) {
        if (!email && !phone) {
            throw new common_1.BadRequestException('Either email or phone must be provided');
        }
        const user = await this.prisma.user.findFirst({
            where: {
                OR: [
                    ...(email ? [{ email }] : []),
                    ...(phone ? [{ phone }] : []),
                ],
            },
        });
        if (!user) {
            throw new common_1.BadRequestException('User not found');
        }
        const otp = await this.otpService.generateOtp(user.id, 'PASSWORD_RESET');
        if (email) {
            await this.mailService.sendPasswordResetOtp(email, otp.code);
        }
        else if (phone) {
            await this.smsService.sendPasswordResetOtp(phone, otp.code);
        }
        return {
            message: `OTP sent to ${email ? 'email' : 'phone'}`,
        };
    }
    async verifyOtp(code, email, phone) {
        if (!email && !phone) {
            throw new common_1.BadRequestException('Either email or phone must be provided');
        }
        const user = await this.prisma.user.findFirst({
            where: {
                OR: [
                    ...(email ? [{ email }] : []),
                    ...(phone ? [{ phone }] : []),
                ],
            },
        });
        if (!user) {
            throw new common_1.BadRequestException('User not found');
        }
        const isValid = await this.otpService.verifyOtp(user.id, code, 'PASSWORD_RESET');
        if (!isValid) {
            throw new common_1.BadRequestException('Invalid or expired OTP');
        }
        return { message: 'OTP verified successfully' };
    }
    async resetPassword(code, newPassword, email, phone) {
        if (!email && !phone) {
            throw new common_1.BadRequestException('Either email or phone must be provided');
        }
        const user = await this.prisma.user.findFirst({
            where: {
                OR: [
                    ...(email ? [{ email }] : []),
                    ...(phone ? [{ phone }] : []),
                ],
            },
        });
        if (!user) {
            throw new common_1.BadRequestException('User not found');
        }
        const isValid = await this.otpService.verifyOtp(user.id, code, 'PASSWORD_RESET');
        if (!isValid) {
            throw new common_1.BadRequestException('Invalid or expired OTP');
        }
        const hashedPassword = await bcrypt.hash(newPassword, 12);
        await this.prisma.user.update({
            where: { id: user.id },
            data: { password: hashedPassword },
        });
        await this.otpService.invalidateOtp(user.id, code);
        return { message: 'Password reset successfully' };
    }
    async generateTokens(userId) {
        const payload = { sub: userId };
        const [accessToken, refreshToken] = await Promise.all([
            this.jwtService.signAsync(payload, {
                secret: this.configService.get('jwt.secret'),
                expiresIn: this.configService.get('jwt.expiresIn'),
            }),
            this.jwtService.signAsync(payload, {
                secret: this.configService.get('jwt.refreshSecret'),
                expiresIn: this.configService.get('jwt.refreshExpiresIn'),
            }),
        ]);
        return { accessToken, refreshToken };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService,
        config_1.ConfigService,
        otp_service_1.OtpService,
        mail_service_1.MailService,
        sms_service_1.SmsService])
], AuthService);
//# sourceMappingURL=auth.service.js.map