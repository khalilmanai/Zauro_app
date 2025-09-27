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
Object.defineProperty(exports, "__esModule", { value: true });
exports.WalletResponseDto = exports.BalanceDto = void 0;
const swagger_1 = require("@nestjs/swagger");
class BalanceDto {
    hbar;
    zau;
}
exports.BalanceDto = BalanceDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '100.12345678',
        description: 'HBAR balance in the account'
    }),
    __metadata("design:type", String)
], BalanceDto.prototype, "hbar", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '1000.50',
        description: 'ZAU token balance in the account'
    }),
    __metadata("design:type", String)
], BalanceDto.prototype, "zau", void 0);
class WalletResponseDto {
    id;
    hederaAccountId;
    publicKey;
    balance;
    createdAt;
}
exports.WalletResponseDto = WalletResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'cm4abc123def456ghi789jkl',
        description: 'Unique wallet identifier'
    }),
    __metadata("design:type", String)
], WalletResponseDto.prototype, "id", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '0.0.123456',
        description: 'Hedera account ID associated with this wallet'
    }),
    __metadata("design:type", String)
], WalletResponseDto.prototype, "hederaAccountId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '302a300506032b65700321004f2b8c8d...',
        description: 'Public key of the Hedera account'
    }),
    __metadata("design:type", String)
], WalletResponseDto.prototype, "publicKey", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        type: BalanceDto,
        description: 'Current wallet balance'
    }),
    __metadata("design:type", BalanceDto)
], WalletResponseDto.prototype, "balance", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '2024-09-27T10:30:00.000Z',
        description: 'Wallet creation timestamp'
    }),
    __metadata("design:type", Date)
], WalletResponseDto.prototype, "createdAt", void 0);
//# sourceMappingURL=wallet-response.dto.js.map