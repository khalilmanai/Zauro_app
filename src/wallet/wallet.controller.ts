import { Controller, Post, Get, Body, UseGuards, Request, Param, Delete } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiBody, ApiParam } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { TransferHbarDto } from './dto/transfer-hbar.dto';
import { TransferResponseDto } from './dto/transfer-response.dto';
import { BalanceResponseDto } from './dto/balance-response.dto';
import { MintNftDto, MintNftResponseDto } from './dto/mint-nft.dto';
import { TransferNftDto, TransferNftResponseDto } from './dto/transfer-nft.dto';
import { CreateCollectionDto, CollectionResponseDto, CollectionStatusDto } from './dto/collection.dto';
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

  // NFT Collection Management
  @Post('collections')
  @ApiOperation({ 
    summary: 'Create a new NFT collection',
    description: 'Creates a new NFT collection on the Hedera network for minting animal NFTs'
  })
  @ApiBody({ 
    type: CreateCollectionDto,
    description: 'Collection details including name, symbol, and max supply'
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Collection created successfully', 
    type: CollectionResponseDto 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async createCollection(@Body() createCollectionDto: CreateCollectionDto): Promise<CollectionResponseDto> {
    return this.walletService.createCollection(createCollectionDto);
  }

  @Get('collections/status')
  @ApiOperation({ 
    summary: 'Get collection status',
    description: 'Retrieves the current status of the NFT collection including minted count and capacity'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Collection status retrieved successfully', 
    type: CollectionStatusDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Collection not found' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getCollectionStatus(): Promise<CollectionStatusDto> {
    return this.walletService.getCollectionStatus();
  }

  @Get('collections/nfts')
  @ApiOperation({ 
    summary: 'Get all NFTs in collection',
    description: 'Retrieves all NFTs minted in the current collection'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Collection NFTs retrieved successfully' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getCollectionNfts(): Promise<any[]> {
    return this.walletService.getCollectionNfts();
  }

  // NFT Operations
  @Post('mint-nft')
  @ApiOperation({ 
    summary: 'Mint a new NFT',
    description: 'Mints a new animal NFT for the authenticated user with provided metadata'
  })
  @ApiBody({ 
    type: MintNftDto,
    description: 'NFT metadata and optional collection token ID'
  })
  @ApiResponse({ 
    status: 201, 
    description: 'NFT minted successfully', 
    type: MintNftResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found - user has not created a wallet yet' 
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid metadata or collection not found' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async mintNft(@Body() mintNftDto: MintNftDto, @Request() req: any): Promise<MintNftResponseDto> {
    return this.walletService.mintNft(req.user.id, mintNftDto);
  }

  @Post('transfer-nft')
  @ApiOperation({ 
    summary: 'Transfer NFT to another account',
    description: 'Transfers an NFT from the authenticated user to another Hedera account'
  })
  @ApiBody({ 
    type: TransferNftDto,
    description: 'Transfer details including token ID, serial number, and recipient account'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'NFT transferred successfully', 
    type: TransferNftResponseDto 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found or NFT not owned by user' 
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid transfer parameters' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async transferNft(@Body() transferNftDto: TransferNftDto, @Request() req: any): Promise<TransferNftResponseDto> {
    return this.walletService.transferNft(req.user.id, transferNftDto);
  }

  @Get('my-nfts')
  @ApiOperation({ 
    summary: 'Get user NFTs',
    description: 'Retrieves all NFTs owned by the authenticated user'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'User NFTs retrieved successfully' 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'Wallet not found - user has not created a wallet yet' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async getUserNfts(@Request() req: any): Promise<any[]> {
    return this.walletService.getUserNfts(req.user.id);
  }

  @Delete('burn-nft/:tokenId/:serialNumber')
  @ApiOperation({ 
    summary: 'Burn an NFT',
    description: 'Burns (destroys) an NFT permanently from the blockchain'
  })
  @ApiParam({
    name: 'tokenId',
    description: 'Token ID of the NFT collection',
    example: '0.0.123456'
  })
  @ApiParam({
    name: 'serialNumber',
    description: 'Serial number of the NFT to burn',
    example: '12345'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'NFT burned successfully' 
  })
  @ApiResponse({ 
    status: 404, 
    description: 'NFT not found' 
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - valid JWT token required' 
  })
  async burnNft(
    @Param('tokenId') tokenId: string, 
    @Param('serialNumber') serialNumber: string, 
    @Request() req: any
  ): Promise<{ transactionHash: string }> {
    return this.walletService.burnNft(req.user.id, tokenId, serialNumber);
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
