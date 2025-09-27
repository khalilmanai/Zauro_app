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
exports.TradesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const trades_service_1 = require("./trades.service");
const create_trade_dto_1 = require("./dto/create-trade.dto");
const trade_response_dto_1 = require("./dto/trade-response.dto");
const pagination_dto_1 = require("../common/dto/pagination.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const client_1 = require("@prisma/client");
let TradesController = class TradesController {
    tradesService;
    constructor(tradesService) {
        this.tradesService = tradesService;
    }
    async createTrade(createTradeDto, req) {
        return this.tradesService.createTrade(createTradeDto, req.user.id);
    }
    async findAll(paginationDto, status) {
        const result = await this.tradesService.findAll(paginationDto, status);
        return {
            success: true,
            message: 'Trades retrieved successfully',
            data: result.trades,
            pagination: {
                page: result.page,
                limit: result.limit,
                total: result.total,
                totalPages: result.totalPages,
            },
            timestamp: new Date().toISOString(),
        };
    }
    async findOne(id) {
        return this.tradesService.findOne(id);
    }
    async buyAnimal(id, req) {
        return this.tradesService.buyAnimal(id, req.user.id);
    }
    async executeTrade(id, req) {
        return this.tradesService.executeTrade(id, req.user.id);
    }
    async cancelTrade(id, req) {
        return this.tradesService.cancelTrade(id, req.user.id);
    }
};
exports.TradesController = TradesController;
__decorate([
    (0, common_1.Post)('list'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)('JWT-auth'),
    (0, swagger_1.ApiOperation)({ summary: 'List an animal for trade' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Animal listed for trade successfully', type: trade_response_dto_1.TradeResponseDto }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_trade_dto_1.CreateTradeDto, Object]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "createTrade", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all trades with pagination' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Trades retrieved successfully' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('status')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [pagination_dto_1.PaginationDto, String]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get trade by ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Trade retrieved successfully', type: trade_response_dto_1.TradeResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Trade not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Post)('buy/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)('JWT-auth'),
    (0, swagger_1.ApiOperation)({ summary: 'Buy an animal (initiate trade)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Trade initiated successfully', type: trade_response_dto_1.TradeResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'Trade not available or insufficient balance' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "buyAnimal", null);
__decorate([
    (0, common_1.Post)('execute/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)('JWT-auth'),
    (0, swagger_1.ApiOperation)({ summary: 'Execute trade (complete atomic swap)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Trade executed successfully', type: trade_response_dto_1.TradeResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 400, description: 'Trade execution failed' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "executeTrade", null);
__decorate([
    (0, common_1.Post)('cancel/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)('JWT-auth'),
    (0, swagger_1.ApiOperation)({ summary: 'Cancel a trade' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Trade cancelled successfully', type: trade_response_dto_1.TradeResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - not your trade' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], TradesController.prototype, "cancelTrade", null);
exports.TradesController = TradesController = __decorate([
    (0, swagger_1.ApiTags)('Trades'),
    (0, common_1.Controller)('trades'),
    __metadata("design:paramtypes", [trades_service_1.TradesService])
], TradesController);
//# sourceMappingURL=trades.controller.js.map