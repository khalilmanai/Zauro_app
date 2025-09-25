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
exports.AnimalsController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const swagger_1 = require("@nestjs/swagger");
const animals_service_1 = require("./animals.service");
const create_animal_dto_1 = require("./dto/create-animal.dto");
const update_animal_dto_1 = require("./dto/update-animal.dto");
const animal_response_dto_1 = require("./dto/animal-response.dto");
const pagination_dto_1 = require("../common/dto/pagination.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
let AnimalsController = class AnimalsController {
    animalsService;
    constructor(animalsService) {
        this.animalsService = animalsService;
    }
    async create(createAnimalDto, req, imageFile) {
        return this.animalsService.createAnimal(createAnimalDto, req.user.id, imageFile);
    }
    async findAll(paginationDto, ownerId) {
        const result = await this.animalsService.findAll(paginationDto, ownerId);
        return {
            success: true,
            message: 'Animals retrieved successfully',
            data: result.animals,
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
        return this.animalsService.findOne(id);
    }
    async update(id, updateAnimalDto, req) {
        return this.animalsService.update(id, updateAnimalDto, req.user.id);
    }
    async remove(id, req) {
        return this.animalsService.remove(id, req.user.id);
    }
    async uploadImage(id, req, imageFile) {
        return this.animalsService.uploadAnimalImage(id, req.user.id, imageFile);
    }
    async uploadVetRecord(id, req, vetRecordFile) {
        return this.animalsService.uploadVetRecord(id, req.user.id, vetRecordFile);
    }
};
exports.AnimalsController = AnimalsController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('image')),
    (0, swagger_1.ApiConsumes)('multipart/form-data'),
    (0, swagger_1.ApiOperation)({ summary: 'Create a new animal and mint NFT' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Animal created and NFT minted successfully', type: animal_response_dto_1.AnimalResponseDto }),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_animal_dto_1.CreateAnimalDto, Object, Object]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all animals with pagination' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Animals retrieved successfully' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('ownerId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [pagination_dto_1.PaginationDto, String]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get animal by ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Animal retrieved successfully', type: animal_response_dto_1.AnimalResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Animal not found' }),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Update animal metadata' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Animal updated successfully', type: animal_response_dto_1.AnimalResponseDto }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - not your animal' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Animal not found' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_animal_dto_1.UpdateAnimalDto, Object]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: 'Delete animal and burn NFT' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Animal deleted and NFT burned successfully' }),
    (0, swagger_1.ApiResponse)({ status: 403, description: 'Forbidden - not your animal' }),
    (0, swagger_1.ApiResponse)({ status: 404, description: 'Animal not found' }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "remove", null);
__decorate([
    (0, common_1.Post)(':id/upload-image'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('image')),
    (0, swagger_1.ApiConsumes)('multipart/form-data'),
    (0, swagger_1.ApiOperation)({ summary: 'Upload animal image' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Image uploaded successfully', type: animal_response_dto_1.AnimalResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "uploadImage", null);
__decorate([
    (0, common_1.Post)(':id/upload-vet-record'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('vetRecord')),
    (0, swagger_1.ApiConsumes)('multipart/form-data'),
    (0, swagger_1.ApiOperation)({ summary: 'Upload vet record' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Vet record uploaded successfully', type: animal_response_dto_1.AnimalResponseDto }),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, Object]),
    __metadata("design:returntype", Promise)
], AnimalsController.prototype, "uploadVetRecord", null);
exports.AnimalsController = AnimalsController = __decorate([
    (0, swagger_1.ApiTags)('Animals'),
    (0, common_1.Controller)('animals'),
    __metadata("design:paramtypes", [animals_service_1.AnimalsService])
], AnimalsController);
//# sourceMappingURL=animals.controller.js.map