import { Controller, Post, Get, Body, UseGuards, Request, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Wallet')
@Controller('wallets')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post('create')
  @ApiOperation({ summary: 'Create a new wallet for the authenticated user' })
  @ApiResponse({ status: 201, description: 'Wallet created successfully', type: WalletResponseDto })
  @ApiResponse({ status: 409, description: 'User already has a wallet' })
  async createWallet(@Request() req: any): Promise<WalletResponseDto> {
    return this.walletService.createWallet(req.user.id);
  }

  @Get('my-wallet')
  @ApiOperation({ summary: 'Get the authenticated user wallet' })
  @ApiResponse({ status: 200, description: 'Wallet retrieved successfully', type: WalletResponseDto })
  @ApiResponse({ status: 404, description: 'Wallet not found' })
  async getMyWallet(@Request() req: any): Promise<WalletResponseDto> {
    return this.walletService.getWallet(req.user.id);
  }

  @Get('my-wallet/balance')
  @ApiOperation({ summary: 'Get the authenticated user wallet balance' })
  @ApiResponse({ status: 200, description: 'Balance retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Wallet not found' })
  async getMyWalletBalance(@Request() req: any): Promise<{ hbar: string; zau: string }> {
    return this.walletService.getWalletBalance(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get wallet by ID' })
  @ApiResponse({ status: 200, description: 'Wallet retrieved successfully', type: WalletResponseDto })
  @ApiResponse({ status: 404, description: 'Wallet not found' })
  async getWallet(@Param('id') id: string): Promise<WalletResponseDto> {
    // This would need additional authorization logic to ensure users can only access their own wallets
    const wallet = await this.walletService.getWallet(id);
    return wallet;
  }

  @Get(':id/balance')
  @ApiOperation({ summary: 'Get wallet balance by wallet ID' })
  @ApiResponse({ status: 200, description: 'Balance retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Wallet not found' })
  async getWalletBalance(@Param('id') id: string): Promise<{ hbar: string; zau: string }> {
    // This would need additional authorization logic
    return this.walletService.getWalletBalance(id);
  }
}
