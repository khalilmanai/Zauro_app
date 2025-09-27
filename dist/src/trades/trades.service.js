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
exports.TradesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const wallet_service_1 = require("../wallet/wallet.service");
const hedera_service_1 = require("../wallet/services/hedera.service");
const encryption_service_1 = require("../wallet/services/encryption.service");
const mail_service_1 = require("../mail/mail.service");
const sms_service_1 = require("../sms/sms.service");
let TradesService = class TradesService {
    prisma;
    walletService;
    hederaService;
    encryptionService;
    mailService;
    smsService;
    constructor(prisma, walletService, hederaService, encryptionService, mailService, smsService) {
        this.prisma = prisma;
        this.walletService = walletService;
        this.hederaService = hederaService;
        this.encryptionService = encryptionService;
        this.mailService = mailService;
        this.smsService = smsService;
    }
    async createTrade(createTradeDto, sellerId) {
        const { animalId, price, currency } = createTradeDto;
        const animal = await this.prisma.animal.findUnique({
            where: { id: animalId },
            include: { owner: true },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        if (animal.ownerId !== sellerId) {
            throw new common_1.ForbiddenException('You can only list your own animals for trade');
        }
        if (animal.isListed) {
            throw new common_1.BadRequestException('Animal is already listed for trade');
        }
        const trade = await this.prisma.trade.create({
            data: {
                animalId,
                sellerId,
                price,
                currency,
                status: 'LISTED',
            },
            include: {
                animal: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                            },
                        },
                    },
                },
                seller: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        await this.prisma.animal.update({
            where: { id: animalId },
            data: { isListed: true },
        });
        return trade;
    }
    async findAll(paginationDto, status) {
        const { page = 1, limit = 10 } = paginationDto;
        const skip = (page - 1) * limit;
        const where = status ? { status } : {};
        const [trades, total] = await Promise.all([
            this.prisma.trade.findMany({
                where,
                skip,
                take: limit,
                include: {
                    animal: {
                        include: {
                            owner: {
                                select: {
                                    id: true,
                                    firstName: true,
                                    lastName: true,
                                },
                            },
                        },
                    },
                    seller: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                    buyer: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                },
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.trade.count({ where }),
        ]);
        return {
            trades,
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
        };
    }
    async findOne(id) {
        const trade = await this.prisma.trade.findUnique({
            where: { id },
            include: {
                animal: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                            },
                        },
                    },
                },
                seller: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
                buyer: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        if (!trade) {
            throw new common_1.NotFoundException('Trade not found');
        }
        return trade;
    }
    async buyAnimal(tradeId, buyerId) {
        const trade = await this.prisma.trade.findUnique({
            where: { id: tradeId },
            include: {
                animal: {
                    include: { owner: true },
                },
                seller: true,
            },
        });
        if (!trade) {
            throw new common_1.NotFoundException('Trade not found');
        }
        if (trade.status !== 'LISTED') {
            throw new common_1.BadRequestException('Trade is not available for purchase');
        }
        if (trade.sellerId === buyerId) {
            throw new common_1.BadRequestException('You cannot buy your own animal');
        }
        const buyerBalance = await this.walletService.getWalletBalance(buyerId);
        const requiredAmount = trade.price.toString();
        if (trade.currency === 'HBAR' && parseFloat(buyerBalance.hbar) < Number(trade.price)) {
            throw new common_1.BadRequestException('Insufficient HBAR balance');
        }
        const updatedTrade = await this.prisma.trade.update({
            where: { id: tradeId },
            data: {
                buyerId,
                status: 'IN_PROGRESS',
            },
            include: {
                animal: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                            },
                        },
                    },
                },
                seller: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
                buyer: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        return updatedTrade;
    }
    async executeTrade(tradeId, userId) {
        const trade = await this.prisma.trade.findUnique({
            where: { id: tradeId },
            include: {
                animal: {
                    include: { owner: true },
                },
                seller: true,
                buyer: true,
            },
        });
        if (!trade) {
            throw new common_1.NotFoundException('Trade not found');
        }
        if (trade.status !== 'IN_PROGRESS') {
            throw new common_1.BadRequestException('Trade is not in progress');
        }
        if (trade.sellerId !== userId && trade.buyerId !== userId) {
            throw new common_1.ForbiddenException('You are not authorized to execute this trade');
        }
        try {
            const sellerWallet = await this.prisma.wallet.findUnique({
                where: { userId: trade.sellerId },
            });
            const buyerWallet = await this.prisma.wallet.findUnique({
                where: { userId: trade.buyerId },
            });
            if (!sellerWallet || !buyerWallet) {
                throw new common_1.BadRequestException('Wallet not found for seller or buyer');
            }
            const buyerPrivateKey = this.encryptionService.decrypt(buyerWallet.encryptedPrivateKey);
            const transactionHash = await this.hederaService.transferHbar(buyerWallet.hederaAccountId, sellerWallet.hederaAccountId, trade.price.toString(), buyerPrivateKey);
            const completedTrade = await this.prisma.trade.update({
                where: { id: tradeId },
                data: {
                    status: 'COMPLETED',
                    transactionHash,
                    completedAt: new Date(),
                },
                include: {
                    animal: {
                        include: {
                            owner: {
                                select: {
                                    id: true,
                                    firstName: true,
                                    lastName: true,
                                },
                            },
                        },
                    },
                    seller: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                    buyer: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                },
            });
            await this.prisma.animal.update({
                where: { id: trade.animalId },
                data: {
                    ownerId: trade.buyerId,
                    isListed: false,
                },
            });
            if (trade.seller.email) {
                await this.mailService.sendTradeNotification(trade.seller.email, 'sold', trade.animal.name);
            }
            if (trade.seller.phone) {
                await this.smsService.sendTradeNotification(trade.seller.phone, 'sold', trade.animal.name);
            }
            if (trade.buyer?.email) {
                await this.mailService.sendTradeNotification(trade.buyer.email, 'purchased', trade.animal.name);
            }
            if (trade.buyer?.phone) {
                await this.smsService.sendTradeNotification(trade.buyer.phone, 'purchased', trade.animal.name);
            }
            return completedTrade;
        }
        catch (error) {
            await this.prisma.trade.update({
                where: { id: tradeId },
                data: { status: 'FAILED' },
            });
            throw new common_1.BadRequestException('Trade execution failed: ' + error.message);
        }
    }
    async cancelTrade(tradeId, userId) {
        const trade = await this.prisma.trade.findUnique({
            where: { id: tradeId },
        });
        if (!trade) {
            throw new common_1.NotFoundException('Trade not found');
        }
        if (trade.sellerId !== userId) {
            throw new common_1.ForbiddenException('You can only cancel your own trades');
        }
        if (trade.status !== 'LISTED' && trade.status !== 'IN_PROGRESS') {
            throw new common_1.BadRequestException('Trade cannot be cancelled');
        }
        const cancelledTrade = await this.prisma.trade.update({
            where: { id: tradeId },
            data: { status: 'CANCELLED' },
            include: {
                animal: {
                    include: {
                        owner: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                            },
                        },
                    },
                },
                seller: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
                buyer: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        await this.prisma.animal.update({
            where: { id: trade.animalId },
            data: { isListed: false },
        });
        return cancelledTrade;
    }
};
exports.TradesService = TradesService;
exports.TradesService = TradesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        wallet_service_1.WalletService,
        hedera_service_1.HederaService,
        encryption_service_1.EncryptionService,
        mail_service_1.MailService,
        sms_service_1.SmsService])
], TradesService);
//# sourceMappingURL=trades.service.js.map