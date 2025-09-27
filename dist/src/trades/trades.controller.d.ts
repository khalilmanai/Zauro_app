import { TradesService } from './trades.service';
import { CreateTradeDto } from './dto/create-trade.dto';
import { TradeResponseDto } from './dto/trade-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { TradeStatus } from '@prisma/client';
export declare class TradesController {
    private readonly tradesService;
    constructor(tradesService: TradesService);
    createTrade(createTradeDto: CreateTradeDto, req: any): Promise<TradeResponseDto>;
    findAll(paginationDto: PaginationDto, status?: TradeStatus): Promise<{
        success: boolean;
        message: string;
        data: TradeResponseDto[];
        pagination: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
        timestamp: string;
    }>;
    findOne(id: string): Promise<TradeResponseDto>;
    buyAnimal(id: string, req: any): Promise<TradeResponseDto>;
    executeTrade(id: string, req: any): Promise<TradeResponseDto>;
    cancelTrade(id: string, req: any): Promise<TradeResponseDto>;
}
