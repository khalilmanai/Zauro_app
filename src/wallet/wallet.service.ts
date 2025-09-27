import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { HederaService } from './services/hedera.service';
import { EncryptionService } from './services/encryption.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { MintNftDto, MintNftResponseDto } from './dto/mint-nft.dto';
import { TransferNftDto, TransferNftResponseDto } from './dto/transfer-nft.dto';
import { CreateCollectionDto, CollectionResponseDto, CollectionStatusDto } from './dto/collection.dto';

@Injectable()
export class WalletService {
  constructor(
    private prisma: PrismaService,
    private hederaService: HederaService,
    private encryptionService: EncryptionService,
  ) {}

  async createWallet(userId: string): Promise<WalletResponseDto> {
    // Check if user already has a wallet
    const existingWallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (existingWallet) {
      throw new ConflictException('User already has a wallet');
    }

    // Create Hedera account
    const hederaAccount = await this.hederaService.createAccount();

    // Encrypt private key
    const encryptedPrivateKey = this.encryptionService.encrypt(hederaAccount.privateKey);

    // Save wallet to database
    const wallet = await this.prisma.wallet.create({
      data: {
        userId,
        hederaAccountId: hederaAccount.accountId,
        encryptedPrivateKey,
        publicKey: hederaAccount.publicKey,
      },
    });

    // Get initial balance
    const balance = await this.hederaService.getAccountBalance(hederaAccount.accountId);

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance,
      createdAt: wallet.createdAt,
    };
  }

  async getWallet(userId: string): Promise<WalletResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    // Get current balance
    const balance = await this.hederaService.getAccountBalance(wallet.hederaAccountId);

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance,
      createdAt: wallet.createdAt,
    };
  }

  async getWalletBalance(userId: string): Promise<{ hbar: string; zau: string }> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    return await this.hederaService.getAccountBalance(wallet.hederaAccountId);
  }

  async transferHbar(userId: string, toAccountId: string, amount: string): Promise<{ transactionHash: string }> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    // Decrypt private key
    const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);

    // Execute transfer
    const transactionHash = await this.hederaService.transferHbar(
      wallet.hederaAccountId,
      toAccountId,
      amount,
      privateKey,
    );

    return { transactionHash };
  }

  async getWalletByAccountId(accountId: string) {
    return await this.prisma.wallet.findUnique({
      where: { hederaAccountId: accountId },
      include: { user: true },
    });
  }

  // NFT Methods
  async createCollection(createCollectionDto: CreateCollectionDto): Promise<CollectionResponseDto> {
    const { tokenId, supplyKey } = await this.hederaService.createCollection(
      createCollectionDto.name,
      createCollectionDto.symbol,
      createCollectionDto.maxSupply || 1000000
    );

    return {
      tokenId,
      supplyKey,
      name: createCollectionDto.name,
      symbol: createCollectionDto.symbol,
      maxSupply: createCollectionDto.maxSupply || 1000000,
    };
  }

  async getCollectionStatus(tokenId?: string): Promise<CollectionStatusDto> {
    try {
      const collection = await this.hederaService.getCollectionStatus(tokenId);
      
      return {
        tokenId: collection.tokenId,
        name: collection.name,
        symbol: collection.symbol,
        nftCount: collection.nftCount,
        maxSupply: collection.maxSupply,
        usagePercentage: collection.usagePercentage,
        status: collection.status,
      };
    } catch (error) {
      throw new NotFoundException('Collection not found or error retrieving status');
    }
  }

  async mintNft(userId: string, mintNftDto: MintNftDto): Promise<MintNftResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    // Decrypt private key
    const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);

    // Mint NFT (external service will use current collection)
    const result = await this.hederaService.mintNft(
      '', // tokenId not needed, service uses current collection
      mintNftDto.metadata,
      wallet.hederaAccountId,
      privateKey
    );

    return {
      serialNumber: result.serialNumber,
      transactionHash: result.transactionHash,
      tokenId: mintNftDto.tokenId || '', // Will be filled by external service
      metadata: mintNftDto.metadata,
    };
  }

  async transferNft(userId: string, transferNftDto: TransferNftDto): Promise<TransferNftResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    // Decrypt private key
    const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);

    // Execute NFT transfer
    const transactionHash = await this.hederaService.transferNft(
      transferNftDto.tokenId,
      transferNftDto.serialNumber,
      wallet.hederaAccountId,
      transferNftDto.toAccountId,
      privateKey
    );

    return {
      transactionHash,
      success: true,
    };
  }

  async getUserNfts(userId: string): Promise<any[]> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found');
    }

    return await this.hederaService.getAccountNfts(wallet.hederaAccountId);
  }

  async getCollectionNfts(tokenId?: string): Promise<any[]> {
    return await this.hederaService.getCollectionNfts(tokenId);
  }

  async burnNft(userId: string, tokenId: string, serialNumber: string): Promise<{ transactionHash: string }> {
    // Note: In a real implementation, you might want to verify ownership before burning
    const transactionHash = await this.hederaService.burnNft(tokenId, serialNumber);
    return { transactionHash };
  }
}
