import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { HederaService } from './services/hedera.service';
import { EncryptionService } from './services/encryption.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { TransferResponseDto } from './dto/transfer-response.dto';
import { FundAccountDto } from './dto/fund-account.dto';

@Injectable()
export class WalletService {
  constructor(
    private prisma: PrismaService,
    private hederaService: HederaService,
    private encryptionService: EncryptionService,
  ) {}

  /**
   * Create a new wallet for a user
   */
  async createWallet(userId: string): Promise<WalletResponseDto> {
    const existingWallet = await this.prisma.wallet.findUnique({ where: { userId } });

    if (existingWallet) {
      throw new ConflictException('User already has a wallet');
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

    const safeBalance = {
      hbar: balance.hbar ?? '0',
      zau: balance.zau ?? '0',
      tokens: balance.tokens ?? {},
      timestamp: new Date().toISOString(),
    };

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance: safeBalance,
      createdAt: wallet.createdAt,
    };
  }

  /**
   * Retrieve a wallet by user ID
   */
  async getWallet(userId: string): Promise<WalletResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found');

    const balance = await this.hederaService.getAccountBalance(wallet.hederaAccountId);

    const safeBalance = {
      hbar: balance.hbar ?? '0',
      zau: balance.zau ?? '0',
      tokens: balance.tokens ?? {},
      timestamp: new Date().toISOString(),
    };

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance: safeBalance,
      createdAt: wallet.createdAt,
    };
  }

  /**
   * Get wallet balance by user ID (lightweight endpoint)
   */
  async getWalletBalance(userId: string): Promise<{
    hbar: string;
    zau: string;
    tokens: Record<string, string>;
    timestamp: string;
  }> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found');

    const balance = await this.hederaService.getAccountBalance(wallet.hederaAccountId);

    return {
      hbar: balance.hbar ?? '0',
      zau: balance.zau ?? '0',
      tokens: balance.tokens ?? {},
      timestamp: new Date().toISOString(),
    };
  }

  /**
   * Transfer HBAR between wallets
   */
  async transferHbar(
    userId: string,
    toAccountId: string,
    amount: string,
  ): Promise<TransferResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found');

    const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);

    const transactionHash = await this.hederaService.transferHbar(
      wallet.hederaAccountId,
      toAccountId,
      amount,
      privateKey,
    );

    return { transactionHash };
  }

  /**
   * Retrieve wallet by Hedera account ID
   */
  async getWalletByAccountId(accountId: string) {
    return this.prisma.wallet.findUnique({
      where: { hederaAccountId: accountId },
      include: { user: true },
    });
  }

  /**
   * Fund a user's wallet with HBAR from the operator account
   */
  async fundUserAccount(
    userId: string,
    amount: string,
    memo?: string,
  ): Promise<TransferResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (!wallet) throw new NotFoundException('Wallet not found. User must create a wallet first.');

    const fundingResult = await this.hederaService.fundAccount(wallet.hederaAccountId, amount, {
      memo: memo || `Funding for user ${userId}`,
    });

    return { transactionHash: fundingResult.transactionId };
  }

  /**
   * Fund a specific Hedera account by account ID
   */
  async fundHederaAccount(
    accountId: string,
    amount: string,
    memo?: string,
  ): Promise<TransferResponseDto> {
    const fundingResult = await this.hederaService.fundAccount(accountId, amount, {
      memo: memo || `Direct funding to account ${accountId}`,
    });

    return { transactionHash: fundingResult.transactionId };
  }

  /**
   * Create a wallet with an initial balance
   */
  async createWalletWithBalance(
    userId: string,
    initialBalance: string,
  ): Promise<WalletResponseDto> {
    const existingWallet = await this.prisma.wallet.findUnique({ where: { userId } });
    if (existingWallet) throw new ConflictException('User already has a wallet');

    const hederaAccount = await this.hederaService.initializeAccountWithBalance(initialBalance);
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

    const safeBalance = {
      hbar: balance.hbar ?? '0',
      zau: balance.zau ?? '0',
      tokens: balance.tokens ?? {},
      timestamp: new Date().toISOString(),
    };

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance: safeBalance,
      createdAt: wallet.createdAt,
    };
  }
}
