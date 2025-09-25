import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { OtpService } from '../otp/otp.service';
import { MailService } from '../mail/mail.service';
import { SmsService } from '../sms/sms.service';
export declare class AuthService {
    private prisma;
    private jwtService;
    private configService;
    private otpService;
    private mailService;
    private smsService;
    constructor(prisma: PrismaService, jwtService: JwtService, configService: ConfigService, otpService: OtpService, mailService: MailService, smsService: SmsService);
    register(registerDto: RegisterDto): Promise<AuthResponseDto>;
    login(loginDto: LoginDto): Promise<AuthResponseDto>;
    refreshToken(userId: string): Promise<{
        accessToken: string;
    }>;
    forgotPasswordRequest(email?: string, phone?: string): Promise<{
        message: string;
    }>;
    verifyOtp(code: string, email?: string, phone?: string): Promise<{
        message: string;
    }>;
    resetPassword(code: string, newPassword: string, email?: string, phone?: string): Promise<{
        message: string;
    }>;
    private generateTokens;
}
