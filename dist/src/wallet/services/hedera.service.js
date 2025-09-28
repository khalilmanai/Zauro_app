"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var HederaService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.HederaService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const sdk_1 = require("@hashgraph/sdk");
let HederaService = HederaService_1 = class HederaService {
    configService;
    logger = new common_1.Logger(HederaService_1.name);
    client;
    networkInfo;
    operatorAccountId;
    operatorPrivateKey;
    constructor(configService) {
        this.configService = configService;
        const config = this.validateAndGetConfig();
        this.networkInfo = this.createNetworkInfo(config.network);
        this.operatorAccountId = sdk_1.AccountId.fromString(config.accountId);
        this.operatorPrivateKey = sdk_1.PrivateKey.fromString(config.privateKey);
        this.initializeClient(config);
    }
    validateAndGetConfig() {
        const accountId = this.configService.get('hedera.accountId');
        const privateKey = this.configService.get('hedera.privateKey');
        const network = this.configService.get('hedera.network', 'testnet');
        const mirrorNodeUrl = this.configService.get('hedera.mirrorNodeUrl');
        if (!accountId || !privateKey) {
            throw new common_1.InternalServerErrorException('Hedera configuration is incomplete. HEDERA_ACCOUNT_ID and HEDERA_PRIVATE_KEY must be set.');
        }
        const accountIdValidation = this.validateAccountId(accountId);
        if (!accountIdValidation.isValid) {
            throw new common_1.InternalServerErrorException(`Invalid HEDERA_ACCOUNT_ID format: ${accountIdValidation.error}`);
        }
        try {
            sdk_1.PrivateKey.fromString(privateKey);
        }
        catch (error) {
            throw new common_1.InternalServerErrorException('Invalid HEDERA_PRIVATE_KEY format');
        }
        return { accountId, privateKey, network, mirrorNodeUrl };
    }
    initializeClient(config) {
        try {
            this.client = sdk_1.Client.forName(config.network);
            this.client.setOperator(this.operatorAccountId, this.operatorPrivateKey);
            this.client.setDefaultMaxTransactionFee(new sdk_1.Hbar(2));
            this.logger.log(`Hedera client initialized for ${config.network} network with operator ${config.accountId}`);
        }
        catch (error) {
            throw new common_1.InternalServerErrorException(`Failed to initialize Hedera client: ${error.message}`);
        }
    }
    createNetworkInfo(network) {
        const networkConfigs = {
            testnet: {
                name: 'Hedera Testnet',
                explorerUrl: 'https://hashscan.io/testnet',
                mirrorNodeUrl: 'https://testnet.mirrornode.hedera.com',
            },
            previewnet: {
                name: 'Hedera Previewnet',
                explorerUrl: 'https://hashscan.io/previewnet',
                mirrorNodeUrl: 'https://previewnet.mirrornode.hedera.com',
            },
            mainnet: {
                name: 'Hedera Mainnet',
                explorerUrl: 'https://hashscan.io/mainnet',
                mirrorNodeUrl: 'https://mainnet.mirrornode.hedera.com',
            },
        };
        return networkConfigs[network] || networkConfigs.testnet;
    }
    generateKeyPair() {
        try {
            const privateKey = sdk_1.PrivateKey.generateED25519();
            const publicKey = privateKey.publicKey.toString();
            this.logger.debug('Generated new ED25519 keypair');
            return {
                privateKey,
                publicKey,
            };
        }
        catch (error) {
            this.logger.error('Failed to generate keypair:', error);
            throw new common_1.InternalServerErrorException('Failed to generate cryptographic keys');
        }
    }
    async createAccount(options = {}) {
        const { initialBalance = 10, memo, maxTransactionFee = 2, } = options;
        try {
            const { privateKey: newPrivateKey, publicKey } = this.generateKeyPair();
            const initialBalanceHbar = new sdk_1.Hbar(initialBalance);
            this.logger.log(`Creating new Hedera account with ${initialBalance} HBAR initial balance`);
            const transaction = new sdk_1.AccountCreateTransaction()
                .setKey(newPrivateKey.publicKey)
                .setInitialBalance(initialBalanceHbar)
                .setMaxTransactionFee(new sdk_1.Hbar(maxTransactionFee));
            if (memo) {
                transaction.setAccountMemo(memo);
            }
            const frozenTransaction = transaction.freezeWith(this.client);
            const response = await frozenTransaction.execute(this.client);
            const receipt = await response.getReceipt(this.client);
            if (receipt.status !== sdk_1.Status.Success) {
                throw new Error(`Account creation failed with status: ${receipt.status.toString()}`);
            }
            if (!receipt.accountId) {
                throw new Error('Account creation failed - no account ID returned in receipt');
            }
            const newAccountId = receipt.accountId.toString();
            const transactionId = response.transactionId.toString();
            this.logger.log(`Successfully created Hedera account: ${newAccountId} with transaction ID: ${transactionId}`);
            return {
                accountId: newAccountId,
                privateKey: newPrivateKey.toString(),
                publicKey,
                transactionId,
                initialBalance: initialBalance.toString(),
            };
        }
        catch (error) {
            this.logger.error('Failed to create Hedera account:', error);
            if (error.message?.includes('INSUFFICIENT_PAYER_BALANCE')) {
                throw new common_1.BadRequestException('Operator account has insufficient balance to create new account');
            }
            if (error.message?.includes('INVALID_ACCOUNT_ID')) {
                throw new common_1.BadRequestException('Invalid account configuration');
            }
            throw new common_1.InternalServerErrorException(`Account creation failed: ${error.message}`);
        }
    }
    async getAccountBalance(accountId) {
        const validation = this.validateAccountId(accountId);
        if (!validation.isValid) {
            throw new common_1.BadRequestException(`Invalid account ID format: ${validation.error}`);
        }
        try {
            const parsedAccountId = sdk_1.AccountId.fromString(accountId);
            const query = new sdk_1.AccountBalanceQuery().setAccountId(parsedAccountId);
            const balance = await query.execute(this.client);
            const hbarBalance = balance.hbars.toString();
            this.logger.debug(`Retrieved HBAR balance for ${accountId}: ${hbarBalance}`);
            let zauBalance = '0';
            const zauTokenId = this.configService.get('hedera.zauTokenId');
            if (zauTokenId) {
                try {
                    const tokenId = sdk_1.TokenId.fromString(zauTokenId);
                    const tokenBalance = balance.tokens?.get(tokenId);
                    if (tokenBalance) {
                        zauBalance = tokenBalance.toString();
                    }
                }
                catch (error) {
                    this.logger.warn(`Failed to get ZAU token balance: ${error.message}`);
                }
            }
            const tokens = {};
            if (balance.tokens) {
                for (const [tokenId, tokenBalance] of balance.tokens) {
                    tokens[tokenId.toString()] = tokenBalance.toString();
                }
            }
            return {
                hbar: hbarBalance,
                zau: zauBalance,
                tokens,
                timestamp: new Date(),
            };
        }
        catch (error) {
            this.logger.error(`Failed to get balance for account ${accountId}:`, error);
            if (error.message?.includes('INVALID_ACCOUNT_ID')) {
                throw new common_1.BadRequestException(`Account ${accountId} does not exist`);
            }
            throw new common_1.InternalServerErrorException(`Failed to retrieve account balance: ${error.message}`);
        }
    }
    async transferHbar(fromAccountId, toAccountId, amount, privateKey) {
        try {
            const fromAccount = sdk_1.AccountId.fromString(fromAccountId);
            const toAccount = sdk_1.AccountId.fromString(toAccountId);
            const transferAmount = new sdk_1.Hbar(parseFloat(amount));
            const senderPrivateKey = sdk_1.PrivateKey.fromString(privateKey);
            const tx = new sdk_1.TransferTransaction()
                .addHbarTransfer(fromAccount, transferAmount.negated())
                .addHbarTransfer(toAccount, transferAmount)
                .freezeWith(this.client);
            const signTx = await tx.sign(senderPrivateKey);
            const submitTx = await signTx.execute(this.client);
            const receipt = await submitTx.getReceipt(this.client);
            if (receipt.status.toString() !== 'SUCCESS') {
                throw new Error(`Transfer failed with status: ${receipt.status.toString()}`);
            }
            const transactionId = submitTx.transactionId.toString();
            this.logger.log(`Successfully transferred ${amount} HBAR from ${fromAccountId} to ${toAccountId}. Transaction ID: ${transactionId}`);
            return transactionId;
        }
        catch (error) {
            this.logger.error('Failed to transfer HBAR:', error);
            throw error;
        }
    }
    async mintNft(tokenId, metadata, privateKey) {
        try {
            const token = sdk_1.TokenId.fromString(tokenId);
            const signerPrivateKey = sdk_1.PrivateKey.fromString(privateKey);
            const tx = new sdk_1.TokenMintTransaction()
                .setTokenId(token)
                .setMetadata([Buffer.from(metadata)])
                .freezeWith(this.client);
            const signTx = await tx.sign(signerPrivateKey);
            const submitTx = await signTx.execute(this.client);
            const receipt = await submitTx.getReceipt(this.client);
            if (receipt.status.toString() !== 'SUCCESS') {
                throw new Error(`NFT minting failed with status: ${receipt.status.toString()}`);
            }
            if (!receipt.serials || receipt.serials.length === 0) {
                throw new Error('NFT minting failed - no serial numbers returned');
            }
            const serialNumber = receipt.serials[0].toString();
            const transactionId = submitTx.transactionId.toString();
            this.logger.log(`Successfully minted NFT: Token ${tokenId}, Serial ${serialNumber}. Transaction ID: ${transactionId}`);
            return {
                serialNumber,
                transactionHash: transactionId,
            };
        }
        catch (error) {
            this.logger.error('Failed to mint NFT:', error);
            throw error;
        }
    }
    async burnNft(tokenId, serialNumber, privateKey) {
        try {
            const token = sdk_1.TokenId.fromString(tokenId);
            const serial = parseInt(serialNumber, 10);
            const signerPrivateKey = sdk_1.PrivateKey.fromString(privateKey);
            const tx = new sdk_1.TokenBurnTransaction()
                .setTokenId(token)
                .setSerials([serial])
                .freezeWith(this.client);
            const signTx = await tx.sign(signerPrivateKey);
            const submitTx = await signTx.execute(this.client);
            const receipt = await submitTx.getReceipt(this.client);
            if (receipt.status.toString() !== 'SUCCESS') {
                throw new Error(`NFT burning failed with status: ${receipt.status.toString()}`);
            }
            const transactionId = submitTx.transactionId.toString();
            this.logger.log(`Successfully burned NFT: Token ${tokenId}, Serial ${serialNumber}. Transaction ID: ${transactionId}`);
            return transactionId;
        }
        catch (error) {
            this.logger.error('Failed to burn NFT:', error);
            throw error;
        }
    }
    async fundAccount(targetAccountId, amount, options = {}) {
        const { memo, maxTransactionFee = 1 } = options;
        const accountValidation = this.validateAccountId(targetAccountId);
        if (!accountValidation.isValid) {
            throw new common_1.BadRequestException(`Invalid target account ID: ${accountValidation.error}`);
        }
        const amountValidation = this.validateAmount(amount);
        if (!amountValidation.isValid) {
            throw new common_1.BadRequestException(`Invalid amount: ${amountValidation.error}`);
        }
        try {
            const toAccount = sdk_1.AccountId.fromString(targetAccountId);
            const fundingAmount = new sdk_1.Hbar(parseFloat(amount));
            const operatorAccountId = this.operatorAccountId;
            this.logger.log(`Funding account ${targetAccountId} with ${amount} HBAR from operator ${operatorAccountId.toString()}`);
            const transaction = new sdk_1.TransferTransaction()
                .addHbarTransfer(operatorAccountId, fundingAmount.negated())
                .addHbarTransfer(toAccount, fundingAmount)
                .setMaxTransactionFee(new sdk_1.Hbar(maxTransactionFee));
            if (memo) {
                transaction.setTransactionMemo(memo);
            }
            const frozenTransaction = transaction.freezeWith(this.client);
            const response = await frozenTransaction.execute(this.client);
            const receipt = await response.getReceipt(this.client);
            if (receipt.status !== sdk_1.Status.Success) {
                throw new Error(`Funding failed with status: ${receipt.status.toString()}`);
            }
            const transactionId = response.transactionId.toString();
            const timestamp = new Date();
            this.logger.log(`Successfully funded account ${targetAccountId} with ${amount} HBAR. Transaction ID: ${transactionId}`);
            return {
                transactionId,
                fromAccountId: operatorAccountId.toString(),
                toAccountId: targetAccountId,
                amount,
                memo,
                timestamp,
            };
        }
        catch (error) {
            this.logger.error('Failed to fund account:', error);
            if (error.message?.includes('INSUFFICIENT_PAYER_BALANCE')) {
                throw new common_1.BadRequestException('Operator account has insufficient balance for funding');
            }
            if (error.message?.includes('INVALID_ACCOUNT_ID')) {
                throw new common_1.BadRequestException(`Target account ${targetAccountId} does not exist`);
            }
            throw new common_1.InternalServerErrorException(`Funding operation failed: ${error.message}`);
        }
    }
    async initializeAccountWithBalance(initialBalance) {
        try {
            const newPrivateKey = sdk_1.PrivateKey.generateED25519();
            const newPublicKey = newPrivateKey.publicKey;
            const balance = new sdk_1.Hbar(parseFloat(initialBalance));
            const tx = new sdk_1.AccountCreateTransaction()
                .setKey(newPublicKey)
                .setInitialBalance(balance)
                .freezeWith(this.client);
            const response = await tx.execute(this.client);
            const receipt = await response.getReceipt(this.client);
            if (!receipt.accountId) {
                throw new Error('Account creation failed - no account ID returned');
            }
            const newAccountId = receipt.accountId;
            const transactionId = response.transactionId.toString();
            this.logger.log(`Successfully created and initialized Hedera account: ${newAccountId.toString()} with ${initialBalance} HBAR`);
            return {
                accountId: newAccountId.toString(),
                privateKey: newPrivateKey.toString(),
                publicKey: newPublicKey.toString(),
                fundingTransactionId: transactionId,
            };
        }
        catch (error) {
            this.logger.error('Failed to initialize account with balance:', error);
            throw error;
        }
    }
    validateAccountId(accountId) {
        if (!accountId || typeof accountId !== 'string') {
            return { isValid: false, error: 'Account ID is required and must be a string' };
        }
        const accountIdRegex = /^0\.0\.[1-9]\d*$/;
        if (!accountIdRegex.test(accountId)) {
            return { isValid: false, error: 'Account ID must be in format 0.0.123456' };
        }
        try {
            sdk_1.AccountId.fromString(accountId);
            return { isValid: true };
        }
        catch (error) {
            return { isValid: false, error: `Invalid account ID format: ${error.message}` };
        }
    }
    validateAmount(amount) {
        if (!amount || typeof amount !== 'string') {
            return { isValid: false, error: 'Amount is required and must be a string' };
        }
        const numericAmount = parseFloat(amount);
        if (isNaN(numericAmount)) {
            return { isValid: false, error: 'Amount must be a valid number' };
        }
        if (numericAmount <= 0) {
            return { isValid: false, error: 'Amount must be greater than 0' };
        }
        if (numericAmount > 50000000000) {
            return { isValid: false, error: 'Amount exceeds maximum allowed value' };
        }
        return { isValid: true };
    }
    getHashScanUrls(accountId, transactionId) {
        const baseUrl = this.networkInfo.explorerUrl;
        const result = {
            accountUrl: `${baseUrl}/account/${accountId}`,
        };
        if (transactionId) {
            result.transactionUrl = `${baseUrl}/transaction/${transactionId}`;
        }
        return result;
    }
    getNetworkInfo() {
        return this.networkInfo;
    }
    getOperatorInfo() {
        return {
            accountId: this.operatorAccountId.toString(),
            network: this.networkInfo.name,
        };
    }
    async validateOperatorBalance(requiredAmount) {
        try {
            const balance = await this.getAccountBalance(this.operatorAccountId.toString());
            const currentBalance = parseFloat(balance.hbar);
            if (currentBalance < requiredAmount) {
                return {
                    isValid: false,
                    error: `Operator account has insufficient balance. Required: ${requiredAmount} HBAR, Available: ${currentBalance} HBAR`,
                };
            }
            return { isValid: true };
        }
        catch (error) {
            return {
                isValid: false,
                error: `Failed to check operator balance: ${error.message}`,
            };
        }
    }
};
exports.HederaService = HederaService;
exports.HederaService = HederaService = HederaService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], HederaService);
//# sourceMappingURL=hedera.service.js.map