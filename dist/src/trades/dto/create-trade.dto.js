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
exports.CreateTradeDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
class CreateTradeDto {
    animalId;
    price;
    currency = 'HBAR';
}
exports.CreateTradeDto = CreateTradeDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'cm4abc123def456ghi789jkl',
        description: 'ID of the animal to list for trade'
    }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTradeDto.prototype, "animalId", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 100.50,
        description: 'Price for the animal trade',
        minimum: 0
    }),
    (0, class_validator_1.IsDecimal)(),
    (0, class_validator_1.Min)(0),
    __metadata("design:type", Number)
], CreateTradeDto.prototype, "price", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'HBAR',
        description: 'Currency for the trade (HBAR or ZAU)',
        default: 'HBAR',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateTradeDto.prototype, "currency", void 0);
//# sourceMappingURL=create-trade.dto.js.map