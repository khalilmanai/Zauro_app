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
exports.CreateAnimalDto = void 0;
const class_validator_1 = require("class-validator");
const swagger_1 = require("@nestjs/swagger");
const client_1 = require("@prisma/client");
class CreateAnimalDto {
    name;
    species;
    breed;
    age;
    description;
    aiPredictionValue;
}
exports.CreateAnimalDto = CreateAnimalDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Buddy',
        description: 'Name of the animal'
    }),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAnimalDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'DOG',
        description: 'Species of the animal',
        enum: client_1.AnimalSpecies,
        enumName: 'AnimalSpecies'
    }),
    (0, class_validator_1.IsEnum)(client_1.AnimalSpecies),
    __metadata("design:type", String)
], CreateAnimalDto.prototype, "species", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Golden Retriever',
        description: 'Breed of the animal (optional)',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAnimalDto.prototype, "breed", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 3,
        description: 'Age of the animal in years (0-50)',
        minimum: 0,
        maximum: 50,
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(50),
    __metadata("design:type", Number)
], CreateAnimalDto.prototype, "age", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 'Friendly and energetic dog, great with children and other pets. Fully house trained and loves outdoor activities.',
        description: 'Detailed description of the animal (optional)',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    __metadata("design:type", String)
], CreateAnimalDto.prototype, "description", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        example: 1500.50,
        description: 'AI-predicted market value of the animal in HBAR (optional)',
        required: false
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDecimal)(),
    __metadata("design:type", Number)
], CreateAnimalDto.prototype, "aiPredictionValue", void 0);
//# sourceMappingURL=create-animal.dto.js.map