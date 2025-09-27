import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { TradesService } from './trades.service';
import { CreateTradeDto } from './dto/create-trade.dto';
import { TradeResponseDto } from './dto/trade-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { TradeStatus } from '@prisma/client';

@ApiTags('Trades')
@Controller('trades')
export class TradesController {
  constructor(private readonly tradesService: TradesService) {}

  @Post('list')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'List an animal for trade' })
  @ApiResponse({ status: 201, description: 'Animal listed for trade successfully', type: TradeResponseDto })
  async createTrade(@Body() createTradeDto: CreateTradeDto, @Request() req: any): Promise<TradeResponseDto> {
    return this.tradesService.createTrade(createTradeDto, req.user.id);
  }

  @Get()
  @ApiOperation({ summary: 'Get all trades with pagination' })
  @ApiResponse({ status: 200, description: 'Trades retrieved successfully' })
  async findAll(@Query() paginationDto: PaginationDto, @Query('status') status?: TradeStatus) {
    const result = await this.tradesService.findAll(paginationDto, status);
    return {
      success: true,
      message: 'Trades retrieved successfully',
      data: result.trades,
      pagination: {
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      },
      timestamp: new Date().toISOString(),
    };
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get trade by ID' })
  @ApiResponse({ status: 200, description: 'Trade retrieved successfully', type: TradeResponseDto })
  @ApiResponse({ status: 404, description: 'Trade not found' })
  async findOne(@Param('id') id: string): Promise<TradeResponseDto> {
    return this.tradesService.findOne(id);
  }

  @Post('buy/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Buy an animal (initiate trade)' })
  @ApiResponse({ status: 200, description: 'Trade initiated successfully', type: TradeResponseDto })
  @ApiResponse({ status: 400, description: 'Trade not available or insufficient balance' })
  async buyAnimal(@Param('id') id: string, @Request() req: any): Promise<TradeResponseDto> {
    return this.tradesService.buyAnimal(id, req.user.id);
  }

  @Post('execute/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Execute trade (complete atomic swap)' })
  @ApiResponse({ status: 200, description: 'Trade executed successfully', type: TradeResponseDto })
  @ApiResponse({ status: 400, description: 'Trade execution failed' })
  async executeTrade(@Param('id') id: string, @Request() req: any): Promise<TradeResponseDto> {
    return this.tradesService.executeTrade(id, req.user.id);
  }

  @Post('cancel/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Cancel a trade' })
  @ApiResponse({ status: 200, description: 'Trade cancelled successfully', type: TradeResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden - not your trade' })
  async cancelTrade(@Param('id') id: string, @Request() req: any): Promise<TradeResponseDto> {
    return this.tradesService.cancelTrade(id, req.user.id);
  }
}
