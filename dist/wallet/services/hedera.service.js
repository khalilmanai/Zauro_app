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
    constructor(configService) {
        this.configService = configService;
        this.initializeClient();
    }
    initializeClient() {
        const accountId = sdk_1.AccountId.fromString(this.configService.get('hedera.accountId') || '0.0.0');
        const privateKey = sdk_1.PrivateKey.fromString(this.configService.get('hedera.privateKey') || '302e020100300506032b657004220420');
        const network = this.configService.get('hedera.network') || 'testnet';
        this.client = sdk_1.Client.forName(network);
        this.client.setOperator(accountId, privateKey);
    }
    async createAccount() {
        try {
            const newPrivateKey = sdk_1.PrivateKey.generateED25519();
            const newPublicKey = newPrivateKey.publicKey;
            const accountId = sdk_1.AccountId.fromString('0.0.' + Math.floor(Math.random() * 1000000));
            return {
                accountId: accountId.toString(),
                privateKey: newPrivateKey.toString(),
                publicKey: newPublicKey.toString(),
            };
        }
        catch (error) {
            this.logger.error('Failed to create Hedera account:', error);
            throw error;
        }
    }
    async getAccountBalance(accountId) {
        try {
            const query = new sdk_1.AccountBalanceQuery().setAccountId(sdk_1.AccountId.fromString(accountId));
            const balance = await query.execute(this.client);
            const hbarBalance = balance.hbars.toString();
            let zauBalance = '0';
            try {
                const zauTokenId = sdk_1.TokenId.fromString('0.0.123456');
                const tokenBalance = balance.tokens?.get(zauTokenId);
                if (tokenBalance) {
                    zauBalance = tokenBalance.toString();
                }
            }
            catch (error) {
                this.logger.warn('ZAU token not found or not configured');
            }
            return {
                hbar: hbarBalance,
                zau: zauBalance,
            };
        }
        catch (error) {
            this.logger.error(`Failed to get balance for account ${accountId}:`, error);
            throw error;
        }
    }
    async transferHbar(fromAccountId, toAccountId, amount, privateKey) {
        try {
            const transactionHash = '0x' + Math.random().toString(16).substr(2, 64);
            this.logger.log(`Mock HBAR transfer: ${amount} from ${fromAccountId} to ${toAccountId}`);
            return transactionHash;
        }
        catch (error) {
            this.logger.error('Failed to transfer HBAR:', error);
            throw error;
        }
    }
    async mintNft(tokenId, metadata, privateKey) {
        try {
            const serialNumber = Math.floor(Math.random() * 1000000).toString();
            const transactionHash = '0x' + Math.random().toString(16).substr(2, 64);
            this.logger.log(`Mock NFT minted: Token ${tokenId}, Serial ${serialNumber}`);
            return { serialNumber, transactionHash };
        }
        catch (error) {
            this.logger.error('Failed to mint NFT:', error);
            throw error;
        }
    }
    async burnNft(tokenId, serialNumber, privateKey) {
        try {
            const transactionHash = '0x' + Math.random().toString(16).substr(2, 64);
            this.logger.log(`Mock NFT burned: Token ${tokenId}, Serial ${serialNumber}`);
            return transactionHash;
        }
        catch (error) {
            this.logger.error('Failed to burn NFT:', error);
            throw error;
        }
    }
};
exports.HederaService = HederaService;
exports.HederaService = HederaService = HederaService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], HederaService);
//# sourceMappingURL=hedera.service.js.map