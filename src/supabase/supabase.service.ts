import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SupabaseService {
  private readonly logger = new Logger(SupabaseService.name);
  private supabase: SupabaseClient;

  constructor(
    private configService: ConfigService,
    private prisma: PrismaService,
  ) {
    this.supabase = createClient(
      this.configService.get<string>('supabase.url') || 'https://default.supabase.co',
      this.configService.get<string>('supabase.serviceRoleKey') || 'default-service-role-key',
    );
  }

  async uploadFile(
    file: Express.Multer.File,
    bucket: string,
    userId: string,
  ): Promise<{ url: string; path: string }> {
    try {
      // Validate file type
      const allowedTypes = this.configService.get<string[]>('upload.allowedFileTypes');
      if (!allowedTypes?.includes(file.mimetype)) {
        throw new BadRequestException(`File type ${file.mimetype} is not allowed`);
      }

      // Validate file size
      const maxSize = this.configService.get<number>('upload.maxFileSize');
      if (file.size > (maxSize || 10485760)) {
        throw new BadRequestException(`File size exceeds maximum allowed size of ${maxSize} bytes`);
      }

      // Generate unique filename
      const timestamp = Date.now();
      const randomString = Math.random().toString(36).substring(2, 15);
      const fileExtension = file.originalname.split('.').pop();
      const fileName = `${timestamp}_${randomString}.${fileExtension}`;
      const filePath = `${userId}/${fileName}`;

      // Upload file to Supabase storage
      const { data, error } = await this.supabase.storage
        .from(bucket)
        .upload(filePath, file.buffer, {
          contentType: file.mimetype,
          upsert: false,
        });

      if (error) {
        this.logger.error('Supabase upload error:', error);
        throw new BadRequestException('Failed to upload file');
      }

      // Get public URL
      const { data: urlData } = this.supabase.storage
        .from(bucket)
        .getPublicUrl(filePath);

      // Save file record to database
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
    } catch (error) {
      this.logger.error('File upload failed:', error);
      throw error;
    }
  }

  async uploadAnimalImage(file: Express.Multer.File, userId: string): Promise<{ url: string; path: string }> {
    return this.uploadFile(file, 'animal-images', userId);
  }

  async uploadVetRecord(file: Express.Multer.File, userId: string): Promise<{ url: string; path: string }> {
    return this.uploadFile(file, 'vet-records', userId);
  }

  async deleteFile(bucket: string, path: string): Promise<void> {
    try {
      const { error } = await this.supabase.storage.from(bucket).remove([path]);
      
      if (error) {
        this.logger.error('Supabase delete error:', error);
        throw new BadRequestException('Failed to delete file');
      }

      this.logger.log(`File deleted successfully: ${path}`);
    } catch (error) {
      this.logger.error('File deletion failed:', error);
      throw error;
    }
  }

  async getFileUrl(bucket: string, path: string): Promise<string> {
    const { data } = this.supabase.storage.from(bucket).getPublicUrl(path);
    return data.publicUrl;
  }

  async createSignedUrl(bucket: string, path: string, expiresIn: number = 3600): Promise<string> {
    const { data, error } = await this.supabase.storage
      .from(bucket)
      .createSignedUrl(path, expiresIn);

    if (error) {
      this.logger.error('Supabase signed URL error:', error);
      throw new BadRequestException('Failed to create signed URL');
    }

    return data.signedUrl;
  }
}
