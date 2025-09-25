import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { HederaService } from '../wallet/services/hedera.service';
import { EncryptionService } from '../wallet/services/encryption.service';
import { MailService } from '../mail/mail.service';
import { SmsService } from '../sms/sms.service';
import { CreateTradeDto } from './dto/create-trade.dto';
import { TradeResponseDto } from './dto/trade-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { TradeStatus } from '@prisma/client';

@Injectable()
export class TradesService {
  constructor(
    private prisma: PrismaService,
    private walletService: WalletService,
    private hederaService: HederaService,
    private encryptionService: EncryptionService,
    private mailService: MailService,
    private smsService: SmsService,
  ) {}

  async createTrade(createTradeDto: CreateTradeDto, sellerId: string): Promise<TradeResponseDto> {
    const { animalId, price, currency } = createTradeDto;

    // Check if animal exists and belongs to seller
    const animal = await this.prisma.animal.findUnique({
      where: { id: animalId },
      include: { owner: true },
    });

    if (!animal) {
      throw new NotFoundException('Animal not found');
    }

    if (animal.ownerId !== sellerId) {
      throw new ForbiddenException('You can only list your own animals for trade');
    }

    if (animal.isListed) {
      throw new BadRequestException('Animal is already listed for trade');
    }

    // Create trade
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

    // Mark animal as listed
    await this.prisma.animal.update({
      where: { id: animalId },
      data: { isListed: true },
    });

    return trade;
  }

  async findAll(paginationDto: PaginationDto, status?: TradeStatus): Promise<{
    trades: TradeResponseDto[];
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  }> {
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

  async findOne(id: string): Promise<TradeResponseDto> {
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
      throw new NotFoundException('Trade not found');
    }

    return trade;
  }

  async buyAnimal(tradeId: string, buyerId: string): Promise<TradeResponseDto> {
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
      throw new NotFoundException('Trade not found');
    }

    if (trade.status !== 'LISTED') {
      throw new BadRequestException('Trade is not available for purchase');
    }

    if (trade.sellerId === buyerId) {
      throw new BadRequestException('You cannot buy your own animal');
    }

    // Check buyer's wallet balance
    const buyerBalance = await this.walletService.getWalletBalance(buyerId);
    const requiredAmount = trade.price.toString();

    if (trade.currency === 'HBAR' && parseFloat(buyerBalance.hbar) < Number(trade.price)) {
      throw new BadRequestException('Insufficient HBAR balance');
    }

    // Update trade with buyer
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

  async executeTrade(tradeId: string, userId: string): Promise<TradeResponseDto> {
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
      throw new NotFoundException('Trade not found');
    }

    if (trade.status !== 'IN_PROGRESS') {
      throw new BadRequestException('Trade is not in progress');
    }

    if (trade.sellerId !== userId && trade.buyerId !== userId) {
      throw new ForbiddenException('You are not authorized to execute this trade');
    }

    try {
      // Execute atomic swap on Hedera
      const sellerWallet = await this.prisma.wallet.findUnique({
        where: { userId: trade.sellerId },
      });

      const buyerWallet = await this.prisma.wallet.findUnique({
        where: { userId: trade.buyerId! },
      });

      if (!sellerWallet || !buyerWallet) {
        throw new BadRequestException('Wallet not found for seller or buyer');
      }

      // Transfer HBAR from buyer to seller
      const buyerPrivateKey = this.encryptionService.decrypt(buyerWallet.encryptedPrivateKey);
      const transactionHash = await this.hederaService.transferHbar(
        buyerWallet.hederaAccountId,
        sellerWallet.hederaAccountId,
        trade.price.toString(),
        buyerPrivateKey,
      );

      // Transfer NFT from seller to buyer (this would be done via smart contract in real implementation)
      // For now, we'll just update the database

      // Update trade as completed
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

      // Update animal ownership
      await this.prisma.animal.update({
        where: { id: trade.animalId },
        data: {
          ownerId: trade.buyerId!,
          isListed: false,
        },
      });

      // Send notifications
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
    } catch (error) {
      // Mark trade as failed
      await this.prisma.trade.update({
        where: { id: tradeId },
        data: { status: 'FAILED' },
      });

      throw new BadRequestException('Trade execution failed: ' + error.message);
    }
  }

  async cancelTrade(tradeId: string, userId: string): Promise<TradeResponseDto> {
    const trade = await this.prisma.trade.findUnique({
      where: { id: tradeId },
    });

    if (!trade) {
      throw new NotFoundException('Trade not found');
    }

    if (trade.sellerId !== userId) {
      throw new ForbiddenException('You can only cancel your own trades');
    }

    if (trade.status !== 'LISTED' && trade.status !== 'IN_PROGRESS') {
      throw new BadRequestException('Trade cannot be cancelled');
    }

    // Update trade status
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

    // Mark animal as not listed
    await this.prisma.animal.update({
      where: { id: trade.animalId },
      data: { isListed: false },
    });

    return cancelledTrade;
  }
}
