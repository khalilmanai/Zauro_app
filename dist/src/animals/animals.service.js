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
exports.AnimalsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const supabase_service_1 = require("../supabase/supabase.service");
const hedera_service_1 = require("../wallet/services/hedera.service");
const encryption_service_1 = require("../wallet/services/encryption.service");
let AnimalsService = class AnimalsService {
    prisma;
    supabaseService;
    hederaService;
    encryptionService;
    constructor(prisma, supabaseService, hederaService, encryptionService) {
        this.prisma = prisma;
        this.supabaseService = supabaseService;
        this.hederaService = hederaService;
        this.encryptionService = encryptionService;
    }
    async createAnimal(createAnimalDto, userId, imageFile, vetRecordFile) {
        let imageUrl;
        let vetRecordUrl;
        if (imageFile) {
            const imageResult = await this.supabaseService.uploadAnimalImage(imageFile, userId);
            imageUrl = imageResult.url;
        }
        if (vetRecordFile) {
            const vetResult = await this.supabaseService.uploadVetRecord(vetRecordFile, userId);
            vetRecordUrl = vetResult.url;
        }
        const animal = await this.prisma.animal.create({
            data: {
                ...createAnimalDto,
                ownerId: userId,
                imageUrl,
                vetRecordUrl,
            },
            include: {
                owner: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        try {
            const wallet = await this.prisma.wallet.findUnique({
                where: { userId },
            });
            if (wallet) {
                const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
                const metadata = JSON.stringify({
                    name: animal.name,
                    species: animal.species,
                    breed: animal.breed,
                    age: animal.age,
                    description: animal.description,
                    image: imageUrl,
                    vetRecord: vetRecordUrl,
                    aiPredictionValue: animal.aiPredictionValue,
                });
                const tokenId = '0.0.123456';
                const nftResult = await this.hederaService.mintNft(tokenId, metadata, privateKey);
                const updatedAnimal = await this.prisma.animal.update({
                    where: { id: animal.id },
                    data: {
                        tokenId,
                        tokenSerialNumber: nftResult.serialNumber,
                    },
                    include: {
                        owner: {
                            select: {
                                id: true,
                                firstName: true,
                                lastName: true,
                                email: true,
                            },
                        },
                    },
                });
                return updatedAnimal;
            }
        }
        catch (error) {
            console.error('NFT minting failed:', error);
        }
        return animal;
    }
    async findAll(paginationDto, ownerId) {
        const { page = 1, limit = 10 } = paginationDto;
        const skip = (page - 1) * limit;
        const where = ownerId ? { ownerId } : {};
        const [animals, total] = await Promise.all([
            this.prisma.animal.findMany({
                where,
                skip,
                take: limit,
                include: {
                    owner: {
                        select: {
                            id: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                },
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.animal.count({ where }),
        ]);
        return {
            animals,
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
        };
    }
    async findOne(id) {
        const animal = await this.prisma.animal.findUnique({
            where: { id },
            include: {
                owner: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        return animal;
    }
    async update(id, updateAnimalDto, userId) {
        const animal = await this.prisma.animal.findUnique({
            where: { id },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        if (animal.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own animals');
        }
        const updatedAnimal = await this.prisma.animal.update({
            where: { id },
            data: updateAnimalDto,
            include: {
                owner: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        return updatedAnimal;
    }
    async remove(id, userId) {
        const animal = await this.prisma.animal.findUnique({
            where: { id },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        if (animal.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only delete your own animals');
        }
        const activeTrade = await this.prisma.trade.findFirst({
            where: {
                animalId: id,
                status: {
                    in: ['PENDING', 'LISTED', 'IN_PROGRESS'],
                },
            },
        });
        if (activeTrade) {
            throw new common_1.BadRequestException('Cannot delete animal that is currently listed for trade');
        }
        if (animal.tokenId && animal.tokenSerialNumber) {
            try {
                const wallet = await this.prisma.wallet.findUnique({
                    where: { userId },
                });
                if (wallet) {
                    const privateKey = this.encryptionService.decrypt(wallet.encryptedPrivateKey);
                    await this.hederaService.burnNft(animal.tokenId, animal.tokenSerialNumber, privateKey);
                }
            }
            catch (error) {
                console.error('NFT burning failed:', error);
            }
        }
        await this.prisma.animal.delete({
            where: { id },
        });
        return { message: 'Animal deleted successfully' };
    }
    async uploadAnimalImage(id, userId, imageFile) {
        const animal = await this.prisma.animal.findUnique({
            where: { id },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        if (animal.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own animals');
        }
        const imageResult = await this.supabaseService.uploadAnimalImage(imageFile, userId);
        const updatedAnimal = await this.prisma.animal.update({
            where: { id },
            data: { imageUrl: imageResult.url },
            include: {
                owner: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        return updatedAnimal;
    }
    async uploadVetRecord(id, userId, vetRecordFile) {
        const animal = await this.prisma.animal.findUnique({
            where: { id },
        });
        if (!animal) {
            throw new common_1.NotFoundException('Animal not found');
        }
        if (animal.ownerId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own animals');
        }
        const vetResult = await this.supabaseService.uploadVetRecord(vetRecordFile, userId);
        const updatedAnimal = await this.prisma.animal.update({
            where: { id },
            data: { vetRecordUrl: vetResult.url },
            include: {
                owner: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        email: true,
                    },
                },
            },
        });
        return updatedAnimal;
    }
};
exports.AnimalsService = AnimalsService;
exports.AnimalsService = AnimalsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        supabase_service_1.SupabaseService,
        hedera_service_1.HederaService,
        encryption_service_1.EncryptionService])
], AnimalsService);
//# sourceMappingURL=animals.service.js.map