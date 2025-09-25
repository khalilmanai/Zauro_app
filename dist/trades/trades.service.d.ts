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
export declare class TradesService {
    private prisma;
    private walletService;
    private hederaService;
    private encryptionService;
    private mailService;
    private smsService;
    constructor(prisma: PrismaService, walletService: WalletService, hederaService: HederaService, encryptionService: EncryptionService, mailService: MailService, smsService: SmsService);
    createTrade(createTradeDto: CreateTradeDto, sellerId: string): Promise<TradeResponseDto>;
    findAll(paginationDto: PaginationDto, status?: TradeStatus): Promise<{
        trades: TradeResponseDto[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    findOne(id: string): Promise<TradeResponseDto>;
    buyAnimal(tradeId: string, buyerId: string): Promise<TradeResponseDto>;
    executeTrade(tradeId: string, userId: string): Promise<TradeResponseDto>;
    cancelTrade(tradeId: string, userId: string): Promise<TradeResponseDto>;
}
