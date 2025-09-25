import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { OtpType } from '@prisma/client';

@Injectable()
export class OtpService {
  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {}

  async generateOtp(userId: string, type: OtpType): Promise<{ code: string }> {
    // Generate random 6-digit OTP
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Calculate expiration time
    const expiresInMinutes = this.configService.get<number>('otp.expiresInMinutes');
    const expiresAt = new Date(Date.now() + (expiresInMinutes || 10) * 60 * 1000);

    // Invalidate any existing OTPs of the same type for this user
    await this.prisma.otp.updateMany({
      where: {
        userId,
        type,
        isUsed: false,
      },
      data: {
        isUsed: true,
        usedAt: new Date(),
      },
    });

    // Create new OTP
    await this.prisma.otp.create({
      data: {
        userId,
        code,
        type,
        expiresAt,
      },
    });

    return { code };
  }

  async verifyOtp(userId: string, code: string, type: OtpType): Promise<boolean> {
    const otp = await this.prisma.otp.findFirst({
      where: {
        userId,
        code,
        type,
        isUsed: false,
        expiresAt: {
          gt: new Date(),
        },
      },
    });

    if (!otp) {
      return false;
    }

    // Mark OTP as used
    await this.prisma.otp.update({
      where: { id: otp.id },
      data: {
        isUsed: true,
        usedAt: new Date(),
      },
    });

    return true;
  }

  async invalidateOtp(userId: string, code: string): Promise<void> {
    await this.prisma.otp.updateMany({
      where: {
        userId,
        code,
        isUsed: false,
      },
      data: {
        isUsed: true,
        usedAt: new Date(),
      },
    });
  }

  async cleanupExpiredOtps(): Promise<void> {
    await this.prisma.otp.deleteMany({
      where: {
        OR: [
          { expiresAt: { lt: new Date() } },
          { isUsed: true },
        ],
      },
    });
  }
}
