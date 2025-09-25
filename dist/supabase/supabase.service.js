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
var SupabaseService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SupabaseService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const supabase_js_1 = require("@supabase/supabase-js");
const prisma_service_1 = require("../prisma/prisma.service");
let SupabaseService = SupabaseService_1 = class SupabaseService {
    configService;
    prisma;
    logger = new common_1.Logger(SupabaseService_1.name);
    supabase;
    constructor(configService, prisma) {
        this.configService = configService;
        this.prisma = prisma;
        this.supabase = (0, supabase_js_1.createClient)(this.configService.get('supabase.url') || 'https://default.supabase.co', this.configService.get('supabase.serviceRoleKey') || 'default-service-role-key');
    }
    async uploadFile(file, bucket, userId) {
        try {
            const allowedTypes = this.configService.get('upload.allowedFileTypes');
            if (!allowedTypes?.includes(file.mimetype)) {
                throw new common_1.BadRequestException(`File type ${file.mimetype} is not allowed`);
            }
            const maxSize = this.configService.get('upload.maxFileSize');
            if (file.size > (maxSize || 10485760)) {
                throw new common_1.BadRequestException(`File size exceeds maximum allowed size of ${maxSize} bytes`);
            }
            const timestamp = Date.now();
            const randomString = Math.random().toString(36).substring(2, 15);
            const fileExtension = file.originalname.split('.').pop();
            const fileName = `${timestamp}_${randomString}.${fileExtension}`;
            const filePath = `${userId}/${fileName}`;
            const { data, error } = await this.supabase.storage
                .from(bucket)
                .upload(filePath, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });
            if (error) {
                this.logger.error('Supabase upload error:', error);
                throw new common_1.BadRequestException('Failed to upload file');
            }
            const { data: urlData } = this.supabase.storage
                .from(bucket)
                .getPublicUrl(filePath);
            await this.prisma.fileUpload.create({
                data: {
                    fileName: fileName,
                    originalName: file.originalname,
                    mimeType: file.mimetype,
                    size: file.size,
                    url: urlData.publicUrl,
                    uploadedBy: userId,
                },
            });
            this.logger.log(`File uploaded successfully: ${fileName}`);
            return {
                url: urlData.publicUrl,
                path: filePath,
            };
        }
        catch (error) {
            this.logger.error('File upload failed:', error);
            throw error;
        }
    }
    async uploadAnimalImage(file, userId) {
        return this.uploadFile(file, 'animal-images', userId);
    }
    async uploadVetRecord(file, userId) {
        return this.uploadFile(file, 'vet-records', userId);
    }
    async deleteFile(bucket, path) {
        try {
            const { error } = await this.supabase.storage.from(bucket).remove([path]);
            if (error) {
                this.logger.error('Supabase delete error:', error);
                throw new common_1.BadRequestException('Failed to delete file');
            }
            this.logger.log(`File deleted successfully: ${path}`);
        }
        catch (error) {
            this.logger.error('File deletion failed:', error);
            throw error;
        }
    }
    async getFileUrl(bucket, path) {
        const { data } = this.supabase.storage.from(bucket).getPublicUrl(path);
        return data.publicUrl;
    }
    async createSignedUrl(bucket, path, expiresIn = 3600) {
        const { data, error } = await this.supabase.storage
            .from(bucket)
            .createSignedUrl(path, expiresIn);
        if (error) {
            this.logger.error('Supabase signed URL error:', error);
            throw new common_1.BadRequestException('Failed to create signed URL');
        }
        return data.signedUrl;
    }
};
exports.SupabaseService = SupabaseService;
exports.SupabaseService = SupabaseService = SupabaseService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService,
        prisma_service_1.PrismaService])
], SupabaseService);
//# sourceMappingURL=supabase.service.js.map