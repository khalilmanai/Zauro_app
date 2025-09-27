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
exports.WalletService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const hedera_service_1 = require("./services/hedera.service");
const encryption_service_1 = require("./services/encryption.service");
let WalletService = class WalletService {
    prisma;
    hederaService;
    encryptionService;
    constructor(prisma, hederaService, encryptionService) {
        this.prisma = prisma;
        this.hederaService = hederaService;
        this.encryptionService = encryptionService;
    }
    async createWallet(userId) {
        const existingWallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (existingWallet) {
            throw new common_1.ConflictException('User already has a wallet');
        }
        const hederaAccount = await this.hederaService.createAccount();
        const encryptedPrivateKey = this.encryptionService.encrypt(hederaAccount.privateKey);
        const wallet = await this.prisma.wallet.create({
            data: {
                userId,
                hederaAccountId: hederaAccount.accountId,
                encryptedPrivateKey,
                publicKey: hederaAccount.publicKey,
            },
        });
        const balance = await this.hederaService.getAccountBalance(hederaAccount.accountId);
        return {
            id: wallet.id,
            hederaAccountId: wallet.hederaAccountId,
            publicKey: wallet.publicKey,
            balance,
            createdAt: wallet.createdAt,
        };
    }
    async getWallet(userId) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
        }
        const balance = await this.hederaService.getAccountBalance(wallet.hederaAccountId);
        return {
            id: wallet.id,
            hederaAccountId: wallet.hederaAccountId,
            publicKey: wallet.publicKey,
            balance,
            createdAt: wallet.createdAt,
        };
    }
    async getWalletBalance(userId) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
        }
        return await this.hederaService.getAccountBalance(wallet.hederaAccountId);
    }
    async transferHbar(userId, toAccountId, amount) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });
        if (!wallet) {
            throw new common_1.NotFoundException('Wallet not found');
        }
        const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
        const transactionHash = await this.hederaService.transferHbar(wallet.hederaAccountId, toAccountId, amount, privateKey);
        return { transactionHash };
    }
    async getWalletByAccountId(accountId) {
        return await this.prisma.wallet.findUnique({
            where: { hederaAccountId: accountId },
            include: { user: true },
        });
    }
};
exports.WalletService = WalletService;
exports.WalletService = WalletService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        hedera_service_1.HederaService,
        encryption_service_1.EncryptionService])
], WalletService);
//# sourceMappingURL=wallet.service.js.map