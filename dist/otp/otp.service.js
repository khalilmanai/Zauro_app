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
Object.defineProperty(exports, "__esModule", { value: true });
exports.OtpService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const prisma_service_1 = require("../prisma/prisma.service");
let OtpService = class OtpService {
    prisma;
    configService;
    constructor(prisma, configService) {
        this.prisma = prisma;
        this.configService = configService;
    }
    async generateOtp(userId, type) {
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresInMinutes = this.configService.get('otp.expiresInMinutes');
        const expiresAt = new Date(Date.now() + (expiresInMinutes || 10) * 60 * 1000);
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
    async verifyOtp(userId, code, type) {
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
        await this.prisma.otp.update({
            where: { id: otp.id },
            data: {
                isUsed: true,
                usedAt: new Date(),
            },
        });
        return true;
    }
    async invalidateOtp(userId, code) {
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
    async cleanupExpiredOtps() {
        await this.prisma.otp.deleteMany({
            where: {
                OR: [
                    { expiresAt: { lt: new Date() } },
                    { isUsed: true },
                ],
            },
        });
    }
};
exports.OtpService = OtpService;
exports.OtpService = OtpService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        config_1.ConfigService])
], OtpService);
//# sourceMappingURL=otp.service.js.map