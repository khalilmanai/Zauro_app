import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { AuthResponseDto } from './dto/auth-response.dto';
import { OtpService } from '../otp/otp.service';
import { MailService } from '../mail/mail.service';
import { SmsService } from '../sms/sms.service';
import { WalletService } from '../wallet/wallet.service';
import { DidService } from '../did/did.service';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
    private otpService: OtpService,
    private mailService: MailService,
    private smsService: SmsService,
    private walletService: WalletService,
    private didService: DidService,
  ) {}

  async register(registerDto: RegisterDto): Promise<AuthResponseDto> {
    const { email, phone, password, firstName, lastName } = registerDto;

    // Check if user already exists
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [
          { email },
          ...(phone ? [{ phone }] : []),
        ],
      },
    });

    if (existingUser) {
      throw new ConflictException('User with this email or phone already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    // Create user
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

    // Create DID for the user
    let didResult = null;
    try {
      didResult = await this.didService.createUserDid(user.id);
      
      // Encrypt and store DID private key
      const encryptedPrivateKey = this.didService['encryptionService'].encrypt(didResult.privateKey);
      
      await this.prisma.user.update({
        where: { id: user.id },
        data: {
          did: didResult.did,
          didPrivateKey: encryptedPrivateKey,
          didDocument: didResult.document as any,
        },
      });

      console.log(`Created DID ${didResult.did} for user ${user.email}`);
    } catch (error) {
      // Log error but don't fail registration if DID creation fails
      console.error('Failed to create DID during registration:', error);
    }

    // Create wallet automatically for new user
    try {
      await this.walletService.createWallet(user.id);
    } catch (error) {
      // Log error but don't fail registration if wallet creation fails
      console.error('Failed to create wallet during registration:', error);
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id);

    return {
      ...tokens,
      user: {
        ...user,
        did: didResult?.did, // Include DID in response
      },
    };
  }

  async login(loginDto: LoginDto): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    // Find user
    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Update last login
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Generate tokens
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

  async refreshToken(userId: string): Promise<{ accessToken: string }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, isActive: true },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const payload = { sub: userId };
    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('jwt.secret'),
      expiresIn: this.configService.get<string>('jwt.expiresIn'),
    });

    return { accessToken };
  }

  async forgotPasswordRequest(email?: string, phone?: string): Promise<{ message: string }> {
    if (!email && !phone) {
      throw new BadRequestException('Either email or phone must be provided');
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
      throw new BadRequestException('User not found');
    }

    // Generate OTP
    const otp = await this.otpService.generateOtp(user.id, 'PASSWORD_RESET');

    // Send OTP via email or SMS
    if (email) {
      await this.mailService.sendPasswordResetOtp(email, otp.code);
    } else if (phone) {
      await this.smsService.sendPasswordResetOtp(phone, otp.code);
    }

    return {
      message: `OTP sent to ${email ? 'email' : 'phone'}`,
    };
  }

  async verifyOtp(code: string, email?: string, phone?: string): Promise<{ message: string }> {
    if (!email && !phone) {
      throw new BadRequestException('Either email or phone must be provided');
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
      throw new BadRequestException('User not found');
    }

    const isValid = await this.otpService.verifyOtp(user.id, code, 'PASSWORD_RESET');
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    return { message: 'OTP verified successfully' };
  }

  async resetPassword(code: string, newPassword: string, email?: string, phone?: string): Promise<{ message: string }> {
    if (!email && !phone) {
      throw new BadRequestException('Either email or phone must be provided');
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
      throw new BadRequestException('User not found');
    }

    // Verify OTP
    const isValid = await this.otpService.verifyOtp(user.id, code, 'PASSWORD_RESET');
    if (!isValid) {
      throw new BadRequestException('Invalid or expired OTP');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Update password
    await this.prisma.user.update({
      where: { id: user.id },
      data: { password: hashedPassword },
    });

    // Invalidate OTP
    await this.otpService.invalidateOtp(user.id, code);

    return { message: 'Password reset successfully' };
  }

  private async generateTokens(userId: string): Promise<{ accessToken: string; refreshToken: string }> {
    const payload = { sub: userId };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.secret'),
        expiresIn: this.configService.get<string>('jwt.expiresIn'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('jwt.refreshSecret'),
        expiresIn: this.configService.get<string>('jwt.refreshExpiresIn'),
      }),
    ]);

    return { accessToken, refreshToken };
  }
}
