/**
 * HederaService Usage Examples
 * 
 * This file demonstrates how to use the production-ready HederaService
 * with proper error handling and verification.
 */

import { HederaService } from '../services/hedera.service';
import { Logger } from '@nestjs/common';

export class HederaServiceExample {
  private readonly logger = new Logger(HederaServiceExample.name);

  constructor(private readonly hederaService: HederaService) {}

  /**
   * Example 1: Create a new account with verification
   */
  async createAccountExample(): Promise<any> {
    try {
      this.logger.log('🚀 Creating new Hedera account...');

      // Create account with custom initial balance
      const result = await this.hederaService.createAccount({
        initialBalance: 25, // 25 HBAR
        memo: 'New user account',
        maxTransactionFee: 2,
      });

      this.logger.log('✅ Account created successfully!');
      this.logger.log(`Account ID: ${result.accountId}`);
      this.logger.log(`Public Key: ${result.publicKey}`);
      this.logger.log(`Transaction ID: ${result.transactionId}`);
      this.logger.log(`Initial Balance: ${result.initialBalance} HBAR`);

      // Generate verification URLs
      const urls = this.hederaService.getHashScanUrls(
        result.accountId,
        result.transactionId
      );

      this.logger.log('🔍 Verification URLs:');
      this.logger.log(`Account: ${urls.accountUrl}`);
      this.logger.log(`Transaction: ${urls.transactionUrl}`);

      // Verify the account balance
      await this.verifyAccountBalance(result.accountId, result.initialBalance);

      // ⚠️ In production, encrypt and store the private key securely
      this.logger.warn('🔐 Remember to encrypt and securely store the private key!');
      
      return result;
    } catch (error) {
      this.logger.error('❌ Failed to create account:', error.message);
      throw error;
    }
  }

  /**
   * Example 2: Fund an existing account
   */
  async fundAccountExample(accountId: string, amount: string): Promise<void> {
    try {
      this.logger.log(`💰 Funding account ${accountId} with ${amount} HBAR...`);

      // Check operator balance first
      const balanceCheck = await this.hederaService.validateOperatorBalance(
        parseFloat(amount) + 1 // Include transaction fee
      );

      if (!balanceCheck.isValid) {
        throw new Error(`Insufficient operator balance: ${balanceCheck.error}`);
      }

      // Fund the account
      const result = await this.hederaService.fundAccount(accountId, amount, {
        memo: `Funding ${amount} HBAR`,
        maxTransactionFee: 1,
      });

      this.logger.log('✅ Funding completed successfully!');
      this.logger.log(`Transaction ID: ${result.transactionId}`);
      this.logger.log(`From: ${result.fromAccountId}`);
      this.logger.log(`To: ${result.toAccountId}`);
      this.logger.log(`Amount: ${result.amount} HBAR`);

      // Generate verification URL
      const urls = this.hederaService.getHashScanUrls(
        result.toAccountId,
        result.transactionId
      );

      this.logger.log('🔍 Verification URLs:');
      this.logger.log(`Account: ${urls.accountUrl}`);
      this.logger.log(`Transaction: ${urls.transactionUrl}`);

      // Verify the updated balance
      await this.verifyAccountBalance(accountId);

    } catch (error) {
      this.logger.error('❌ Failed to fund account:', error.message);
      throw error;
    }
  }

  /**
   * Example 3: Check account balance with comprehensive information
   */
  async checkBalanceExample(accountId: string): Promise<void> {
    try {
      this.logger.log(`📊 Checking balance for account ${accountId}...`);

      const balance = await this.hederaService.getAccountBalance(accountId);

      this.logger.log('✅ Balance retrieved successfully!');
      this.logger.log(`HBAR Balance: ${balance.hbar}`);
      this.logger.log(`ZAU Balance: ${balance.zau}`);
      
      if (balance.tokens && Object.keys(balance.tokens).length > 0) {
        this.logger.log('🪙 Token Balances:');
        for (const [tokenId, tokenBalance] of Object.entries(balance.tokens)) {
          this.logger.log(`  ${tokenId}: ${tokenBalance}`);
        }
      }

      this.logger.log(`Query Time: ${balance.timestamp.toISOString()}`);

      // Generate HashScan URL for verification
      const urls = this.hederaService.getHashScanUrls(accountId);
      this.logger.log(`🔍 Verify on HashScan: ${urls.accountUrl}`);

    } catch (error) {
      this.logger.error('❌ Failed to check balance:', error.message);
      throw error;
    }
  }

  /**
   * Example 4: Generate keypair for non-custodial approach
   */
  generateKeypairExample(): void {
    try {
      this.logger.log('🔑 Generating new ED25519 keypair...');

      const { privateKey, publicKey } = this.hederaService.generateKeyPair();

      this.logger.log('✅ Keypair generated successfully!');
      this.logger.log(`Public Key: ${publicKey}`);
      this.logger.log(`Private Key: ${privateKey.toString()}`);

      // In non-custodial approach:
      // 1. Send public key to user
      // 2. User stores private key securely
      // 3. User signs transactions client-side
      // 4. Backend only executes pre-signed transactions

      this.logger.warn('🔐 For non-custodial: User must store private key securely!');

    } catch (error) {
      this.logger.error('❌ Failed to generate keypair:', error.message);
      throw error;
    }
  }

  /**
   * Example 5: Comprehensive service information
   */
  getServiceInfoExample(): void {
    try {
      // Get network information
      const networkInfo = this.hederaService.getNetworkInfo();
      this.logger.log('🌐 Network Information:');
      this.logger.log(`Name: ${networkInfo.name}`);
      this.logger.log(`Explorer: ${networkInfo.explorerUrl}`);
      this.logger.log(`Mirror Node: ${networkInfo.mirrorNodeUrl}`);

      // Get operator information
      const operatorInfo = this.hederaService.getOperatorInfo();
      this.logger.log('🏢 Operator Information:');
      this.logger.log(`Account ID: ${operatorInfo.accountId}`);
      this.logger.log(`Network: ${operatorInfo.network}`);

      // Generate operator HashScan URL
      const operatorUrls = this.hederaService.getHashScanUrls(operatorInfo.accountId);
      this.logger.log(`🔍 Operator on HashScan: ${operatorUrls.accountUrl}`);

    } catch (error) {
      this.logger.error('❌ Failed to get service info:', error.message);
      throw error;
    }
  }

  /**
   * Helper method to verify account balance
   */
  private async verifyAccountBalance(
    accountId: string,
    expectedBalance?: string
  ): Promise<void> {
    try {
      // Wait a moment for consensus
      await new Promise(resolve => setTimeout(resolve, 3000));

      const balance = await this.hederaService.getAccountBalance(accountId);
      
      if (expectedBalance) {
        const actualBalance = parseFloat(balance.hbar);
        const expected = parseFloat(expectedBalance);
        
        if (Math.abs(actualBalance - expected) < 0.001) { // Allow for small rounding differences
          this.logger.log(`✅ Balance verified: ${balance.hbar} HBAR`);
        } else {
          this.logger.warn(`⚠️ Balance mismatch: Expected ${expected}, Got ${actualBalance}`);
        }
      } else {
        this.logger.log(`💰 Current balance: ${balance.hbar} HBAR`);
      }

    } catch (error) {
      this.logger.error('❌ Failed to verify balance:', error.message);
    }
  }

  /**
   * Example 6: Error handling patterns
   */
  async errorHandlingExample(): Promise<void> {
    try {
      // Example of handling various error scenarios
      
      // 1. Invalid account ID format
      try {
        await this.hederaService.getAccountBalance('invalid-account-id');
      } catch (error) {
        this.logger.warn('Expected error for invalid account ID:', error.message);
      }

      // 2. Account doesn't exist
      try {
        await this.hederaService.getAccountBalance('0.0.999999999');
      } catch (error) {
        this.logger.warn('Expected error for non-existent account:', error.message);
      }

      // 3. Invalid amount
      try {
        await this.hederaService.fundAccount('0.0.123456', 'invalid-amount');
      } catch (error) {
        this.logger.warn('Expected error for invalid amount:', error.message);
      }

      // 4. Check operator balance before operations
      const operatorInfo = this.hederaService.getOperatorInfo();
      const balanceCheck = await this.hederaService.validateOperatorBalance(1000000); // 1M HBAR
      
      if (!balanceCheck.isValid) {
        this.logger.log('Operator balance validation (expected):', balanceCheck.error);
      }

    } catch (error) {
      this.logger.error('Unexpected error in error handling example:', error.message);
    }
  }
}

/**
 * Usage in your application:
 * 
 * ```typescript
 * // In your service or controller
 * const example = new HederaServiceExample(hederaService);
 * 
 * // Create a new account
 * await example.createAccountExample();
 * 
 * // Fund an existing account
 * await example.fundAccountExample('0.0.123456', '50.0');
 * 
 * // Check balance
 * await example.checkBalanceExample('0.0.123456');
 * ```
 */
