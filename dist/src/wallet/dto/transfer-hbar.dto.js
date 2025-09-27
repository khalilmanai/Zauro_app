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
exports.TransferHbarDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class TransferHbarDto {
    toAccountId;
    amount;
}
exports.TransferHbarDto = TransferHbarDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '0.0.654321',
        description: 'Destination Hedera account ID',
        pattern: '^0\\.0\\.[0-9]+$'
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.Matches)(/^0\.0\.[0-9]+$/, {
        message: 'toAccountId must be a valid Hedera account ID format (0.0.123456)'
    }),
    __metadata("design:type", String)
], TransferHbarDto.prototype, "toAccountId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: '10.5',
        description: 'Amount of HBAR to transfer (in HBAR, not tinybars)',
        pattern: '^[0-9]+(\\.[0-9]+)?$'
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.IsNotEmpty)(),
    (0, class_validator_1.Matches)(/^[0-9]+(\.[0-9]+)?$/, {
        message: 'amount must be a valid positive number'
    }),
    __metadata("design:type", String)
], TransferHbarDto.prototype, "amount", void 0);
//# sourceMappingURL=transfer-hbar.dto.js.map