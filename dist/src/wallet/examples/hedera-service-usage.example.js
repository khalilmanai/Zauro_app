"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HederaServiceExample = void 0;
const common_1 = require("@nestjs/common");
class HederaServiceExample {
    hederaService;
    logger = new common_1.Logger(HederaServiceExample.name);
    constructor(hederaService) {
        this.hederaService = hederaService;
    }
    async createAccountExample() {
        try {
            this.logger.log('🚀 Creating new Hedera account...');
            const result = await this.hederaService.createAccount({
                initialBalance: 25,
                memo: 'New user account',
                maxTransactionFee: 2,
            });
            this.logger.log('✅ Account created successfully!');
            this.logger.log(`Account ID: ${result.accountId}`);
            this.logger.log(`Public Key: ${result.publicKey}`);
            this.logger.log(`Transaction ID: ${result.transactionId}`);
            this.logger.log(`Initial Balance: ${result.initialBalance} HBAR`);
            const urls = this.hederaService.getHashScanUrls(result.accountId, result.transactionId);
            this.logger.log('🔍 Verification URLs:');
            this.logger.log(`Account: ${urls.accountUrl}`);
            this.logger.log(`Transaction: ${urls.transactionUrl}`);
            await this.verifyAccountBalance(result.accountId, result.initialBalance);
            this.logger.warn('🔐 Remember to encrypt and securely store the private key!');
            return result;
        }
        catch (error) {
            this.logger.error('❌ Failed to create account:', error.message);
            throw error;
        }
    }
    async fundAccountExample(accountId, amount) {
        try {
            this.logger.log(`💰 Funding account ${accountId} with ${amount} HBAR...`);
            const balanceCheck = await this.hederaService.validateOperatorBalance(parseFloat(amount) + 1);
            if (!balanceCheck.isValid) {
                throw new Error(`Insufficient operator balance: ${balanceCheck.error}`);
            }
            const result = await this.hederaService.fundAccount(accountId, amount, {
                memo: `Funding ${amount} HBAR`,
                maxTransactionFee: 1,
            });
            this.logger.log('✅ Funding completed successfully!');
            this.logger.log(`Transaction ID: ${result.transactionId}`);
            this.logger.log(`From: ${result.fromAccountId}`);
            this.logger.log(`To: ${result.toAccountId}`);
            this.logger.log(`Amount: ${result.amount} HBAR`);
            const urls = this.hederaService.getHashScanUrls(result.toAccountId, result.transactionId);
            this.logger.log('🔍 Verification URLs:');
            this.logger.log(`Account: ${urls.accountUrl}`);
            this.logger.log(`Transaction: ${urls.transactionUrl}`);
            await this.verifyAccountBalance(accountId);
        }
        catch (error) {
            this.logger.error('❌ Failed to fund account:', error.message);
            throw error;
        }
    }
    async checkBalanceExample(accountId) {
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
            const urls = this.hederaService.getHashScanUrls(accountId);
            this.logger.log(`🔍 Verify on HashScan: ${urls.accountUrl}`);
        }
        catch (error) {
            this.logger.error('❌ Failed to check balance:', error.message);
            throw error;
        }
    }
    generateKeypairExample() {
        try {
            this.logger.log('🔑 Generating new ED25519 keypair...');
            const { privateKey, publicKey } = this.hederaService.generateKeyPair();
            this.logger.log('✅ Keypair generated successfully!');
            this.logger.log(`Public Key: ${publicKey}`);
            this.logger.log(`Private Key: ${privateKey.toString()}`);
            this.logger.warn('🔐 For non-custodial: User must store private key securely!');
        }
        catch (error) {
            this.logger.error('❌ Failed to generate keypair:', error.message);
            throw error;
        }
    }
    getServiceInfoExample() {
        try {
            const networkInfo = this.hederaService.getNetworkInfo();
            this.logger.log('🌐 Network Information:');
            this.logger.log(`Name: ${networkInfo.name}`);
            this.logger.log(`Explorer: ${networkInfo.explorerUrl}`);
            this.logger.log(`Mirror Node: ${networkInfo.mirrorNodeUrl}`);
            const operatorInfo = this.hederaService.getOperatorInfo();
            this.logger.log('🏢 Operator Information:');
            this.logger.log(`Account ID: ${operatorInfo.accountId}`);
            this.logger.log(`Network: ${operatorInfo.network}`);
            const operatorUrls = this.hederaService.getHashScanUrls(operatorInfo.accountId);
            this.logger.log(`🔍 Operator on HashScan: ${operatorUrls.accountUrl}`);
        }
        catch (error) {
            this.logger.error('❌ Failed to get service info:', error.message);
            throw error;
        }
    }
    async verifyAccountBalance(accountId, expectedBalance) {
        try {
            await new Promise(resolve => setTimeout(resolve, 3000));
            const balance = await this.hederaService.getAccountBalance(accountId);
            if (expectedBalance) {
                const actualBalance = parseFloat(balance.hbar);
                const expected = parseFloat(expectedBalance);
                if (Math.abs(actualBalance - expected) < 0.001) {
                    this.logger.log(`✅ Balance verified: ${balance.hbar} HBAR`);
                }
                else {
                    this.logger.warn(`⚠️ Balance mismatch: Expected ${expected}, Got ${actualBalance}`);
                }
            }
            else {
                this.logger.log(`💰 Current balance: ${balance.hbar} HBAR`);
            }
        }
        catch (error) {
            this.logger.error('❌ Failed to verify balance:', error.message);
        }
    }
    async errorHandlingExample() {
        try {
            try {
                await this.hederaService.getAccountBalance('invalid-account-id');
            }
            catch (error) {
                this.logger.warn('Expected error for invalid account ID:', error.message);
            }
            try {
                await this.hederaService.getAccountBalance('0.0.999999999');
            }
            catch (error) {
                this.logger.warn('Expected error for non-existent account:', error.message);
            }
            try {
                await this.hederaService.fundAccount('0.0.123456', 'invalid-amount');
            }
            catch (error) {
                this.logger.warn('Expected error for invalid amount:', error.message);
            }
            const operatorInfo = this.hederaService.getOperatorInfo();
            const balanceCheck = await this.hederaService.validateOperatorBalance(1000000);
            if (!balanceCheck.isValid) {
                this.logger.log('Operator balance validation (expected):', balanceCheck.error);
            }
        }
        catch (error) {
            this.logger.error('Unexpected error in error handling example:', error.message);
        }
    }
}
exports.HederaServiceExample = HederaServiceExample;
//# sourceMappingURL=hedera-service-usage.example.js.map