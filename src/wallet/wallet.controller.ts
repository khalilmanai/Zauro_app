import { Controller, Post, Get, Body, UseGuards, Request, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { TransferHbarDto } from './dto/transfer-hbar.dto';
import { TransferResponseDto } from './dto/transfer-response.dto';
import { BalanceResponseDto } from './dto/balance-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Wallet')
@Controller('wallets')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post('create')
  @ApiOperation({ 
    summary: 'Create a new wallet for the authenticated user',
    description: 'Creates a new Hedera wallet for the authenticated user. Each user can only have one wallet. The wallet includes a Hedera account with HBAR and ZAU token support.'
  })
  @ApiBody({ 
    type: CreateWalletDto, 
    required: false,
    description: 'Optional wallet creation parameters (userId is ignored - uses authenticated user)'
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Wallet created successfully with Hedera account and initial balance', 
    type: WalletResponseDto 
  })
  @ApiResponse({ 
    status: 409, 
    description: 'User already has a wallet - only one wallet per user is allowed' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async createWallet(@Body() createWalletDto: CreateWalletDto, @Request() req: any): Promise<WalletResponseDto> {
    return this.walletService.createWallet(req.user.id);
  }

  @Get('my-wallet')
  @ApiOperation({ 
    summary: 'Get the authenticated user wallet',
    description: 'Retrieves the wallet information for the currently authenticated user, including current balance from Hedera network'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Wallet retrieved successfully with current balance', 
    type: WalletResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found - user has not created a wallet yet' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getMyWallet(@Request() req: any): Promise<WalletResponseDto> {
    return this.walletService.getWallet(req.user.id);
  }

  @Get('my-wallet/balance')
  @ApiOperation({ 
    summary: 'Get the authenticated user wallet balance',
    description: 'Retrieves the current HBAR and ZAU token balance for the authenticated user wallet from Hedera network'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Balance retrieved successfully from Hedera network', 
    type: BalanceResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found - user has not created a wallet yet' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getMyWalletBalance(@Request() req: any): Promise<BalanceResponseDto> {
    return this.walletService.getWalletBalance(req.user.id);
  }

  @Post('transfer/hbar')
  @ApiOperation({ 
    summary: 'Transfer HBAR to another account',
    description: 'Transfers HBAR from the authenticated user wallet to another Hedera account. Requires sufficient balance and valid destination account.'
  })
  @ApiBody({ 
    type: TransferHbarDto,
    description: 'Transfer details including destination account and amount'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'HBAR transfer completed successfully', 
    type: TransferResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found - user has not created a wallet yet' 
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid transfer parameters or insufficient balance' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async transferHbar(@Body() transferDto: TransferHbarDto, @Request() req: any): Promise<TransferResponseDto> {
    return this.walletService.transferHbar(req.user.id, transferDto.toAccountId, transferDto.amount);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Get wallet by ID',
    description: 'Retrieves wallet information by wallet ID. Note: This endpoint needs additional authorization logic in production.'
  })
  @ApiParam({
    name: 'id',
    description: 'Wallet ID or User ID',
    example: 'cm4abc123def456ghi789jkl'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Wallet retrieved successfully', 
    type: WalletResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getWallet(@Param('id') id: string): Promise<WalletResponseDto> {
    // TODO: Add authorization logic to ensure users can only access their own wallets
    const wallet = await this.walletService.getWallet(id);
    return wallet;
  }

  @Get(':id/balance')
  @ApiOperation({ 
    summary: 'Get wallet balance by wallet ID',
    description: 'Retrieves wallet balance by wallet ID. Note: This endpoint needs additional authorization logic in production.'
  })
  @ApiParam({
    name: 'id',
    description: 'Wallet ID or User ID',
    example: 'cm4abc123def456ghi789jkl'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Balance retrieved successfully', 
    type: BalanceResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getWalletBalance(@Param('id') id: string): Promise<BalanceResponseDto> {
    // TODO: Add authorization logic to ensure users can only access their own wallets
    return this.walletService.getWalletBalance(id);
  }
}
