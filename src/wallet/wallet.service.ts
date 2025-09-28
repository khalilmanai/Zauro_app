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

  async transferHbar(userId: string, toAccountId: string, amount: string): Promise<TransferResponseDto> {
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

  /**
   * Fund a user's wallet with HBAR from the operator account
   * This is useful for topping up user accounts or providing initial funding
   */
  async fundUserAccount(userId: string, amount: string, memo?: string): Promise<TransferResponseDto> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new NotFoundException('Wallet not found. User must create a wallet first.');
    }

    // Fund the user's account using the operator account
    const fundingResult = await this.hederaService.fundAccount(
      wallet.hederaAccountId,
      amount,
      {
        memo: memo || `Funding for user ${userId}`
      }
    );

    return {
      transactionHash: fundingResult.transactionId,
    };
  }

  /**
   * Fund a specific Hedera account with HBAR from the operator account
   * This allows funding any account by account ID (not just user wallets)
   */
  async fundHederaAccount(accountId: string, amount: string, memo?: string): Promise<TransferResponseDto> {
    // Fund the specified account using the operator account
    const fundingResult = await this.hederaService.fundAccount(
      accountId,
      amount,
      {
        memo: memo || `Direct funding to account ${accountId}`
      }
    );

    return {
      transactionHash: fundingResult.transactionId,
    };
  }

  /**
   * Create a new wallet with custom initial HBAR balance
   * Alternative to createWallet() that allows specifying the initial balance
   */
  async createWalletWithBalance(userId: string, initialBalance: string): Promise<WalletResponseDto> {
    // Check if user already has a wallet
    const existingWallet = await this.prisma.wallet.findUnique({
      where: { userId },
    });

    if (existingWallet) {
      throw new ConflictException('User already has a wallet');
    }

    // Create Hedera account with custom initial balance
    const hederaAccount = await this.hederaService.initializeAccountWithBalance(initialBalance);

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

    // Get current balance to confirm
    const balance = await this.hederaService.getAccountBalance(hederaAccount.accountId);

    return {
      id: wallet.id,
      hederaAccountId: wallet.hederaAccountId,
      publicKey: wallet.publicKey,
      balance,
      createdAt: wallet.createdAt,
    };
  }
}
