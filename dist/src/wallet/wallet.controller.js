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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.WalletController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const wallet_service_1 = require("./wallet.service");
const create_wallet_dto_1 = require("./dto/create-wallet.dto");
const wallet_response_dto_1 = require("./dto/wallet-response.dto");
const transfer_hbar_dto_1 = require("./dto/transfer-hbar.dto");
const transfer_response_dto_1 = require("./dto/transfer-response.dto");
const balance_response_dto_1 = require("./dto/balance-response.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let WalletController = class WalletController {
    walletService;
    constructor(walletService) {
        this.walletService = walletService;
    }
    async createWallet(createWalletDto, req) {
        return this.walletService.createWallet(req.user.id);
    }
    async getMyWallet(req) {
        return this.walletService.getWallet(req.user.id);
    }
    async getMyWalletBalance(req) {
        return this.walletService.getWalletBalance(req.user.id);
    }
    async transferHbar(transferDto, req) {
        return this.walletService.transferHbar(req.user.id, transferDto.toAccountId, transferDto.amount);
    }
    async getWallet(id) {
        const wallet = await this.walletService.getWallet(id);
        return wallet;
    }
    async getWalletBalance(id) {
        return this.walletService.getWalletBalance(id);
    }
};
exports.WalletController = WalletController;
__decorate([
    (0, common_1.Post)('create'),
    (0, swagger_1.ApiOperation)({
        summary: 'Create a new wallet for the authenticated user',
        description: 'Creates a new Hedera wallet for the authenticated user. Each user can only have one wallet. The wallet includes a Hedera account with HBAR and ZAU token support.'
    }),
    (0, swagger_1.ApiBody)({
        type: create_wallet_dto_1.CreateWalletDto,
        required: false,
        description: 'Optional wallet creation parameters (userId is ignored - uses authenticated user)'
    }),
    (0, swagger_1.ApiResponse)({
        status: 201,
        description: 'Wallet created successfully with Hedera account and initial balance',
        type: wallet_response_dto_1.WalletResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 409,
        description: 'User already has a wallet - only one wallet per user is allowed'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_wallet_dto_1.CreateWalletDto, Object]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "createWallet", null);
__decorate([
    (0, common_1.Get)('my-wallet'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get the authenticated user wallet',
        description: 'Retrieves the wallet information for the currently authenticated user, including current balance from Hedera network'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Wallet retrieved successfully with current balance',
        type: wallet_response_dto_1.WalletResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Wallet not found - user has not created a wallet yet'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "getMyWallet", null);
__decorate([
    (0, common_1.Get)('my-wallet/balance'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get the authenticated user wallet balance',
        description: 'Retrieves the current HBAR and ZAU token balance for the authenticated user wallet from Hedera network'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Balance retrieved successfully from Hedera network',
        type: balance_response_dto_1.BalanceResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Wallet not found - user has not created a wallet yet'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "getMyWalletBalance", null);
__decorate([
    (0, common_1.Post)('transfer/hbar'),
    (0, swagger_1.ApiOperation)({
        summary: 'Transfer HBAR to another account',
        description: 'Transfers HBAR from the authenticated user wallet to another Hedera account. Requires sufficient balance and valid destination account.'
    }),
    (0, swagger_1.ApiBody)({
        type: transfer_hbar_dto_1.TransferHbarDto,
        description: 'Transfer details including destination account and amount'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'HBAR transfer completed successfully',
        type: transfer_response_dto_1.TransferResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Wallet not found - user has not created a wallet yet'
    }),
    (0, swagger_1.ApiResponse)({
        status: 400,
        description: 'Invalid transfer parameters or insufficient balance'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [transfer_hbar_dto_1.TransferHbarDto, Object]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "transferHbar", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get wallet by ID',
        description: 'Retrieves wallet information by wallet ID. Note: This endpoint needs additional authorization logic in production.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Wallet ID or User ID',
        example: 'cm4abc123def456ghi789jkl'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Wallet retrieved successfully',
        type: wallet_response_dto_1.WalletResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Wallet not found'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "getWallet", null);
__decorate([
    (0, common_1.Get)(':id/balance'),
    (0, swagger_1.ApiOperation)({
        summary: 'Get wallet balance by wallet ID',
        description: 'Retrieves wallet balance by wallet ID. Note: This endpoint needs additional authorization logic in production.'
    }),
    (0, swagger_1.ApiParam)({
        name: 'id',
        description: 'Wallet ID or User ID',
        example: 'cm4abc123def456ghi789jkl'
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'Balance retrieved successfully',
        type: balance_response_dto_1.BalanceResponseDto
    }),
    (0, swagger_1.ApiResponse)({
        status: 404,
        description: 'Wallet not found'
    }),
    (0, swagger_1.ApiResponse)({
        status: 401,
        description: 'Unauthorized - valid JWT token required'
    }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], WalletController.prototype, "getWalletBalance", null);
exports.WalletController = WalletController = __decorate([
    (0, swagger_1.ApiTags)('Wallet'),
    (0, common_1.Controller)('wallets'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)('JWT-auth'),
    __metadata("design:paramtypes", [wallet_service_1.WalletService])
], WalletController);
//# sourceMappingURL=wallet.controller.js.map