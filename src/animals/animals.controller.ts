import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  Query,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { AnimalsService } from './animals.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { AnimalResponseDto } from './dto/animal-response.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Animals')
@Controller('animals')
export class AnimalsController {
  constructor(private readonly animalsService: AnimalsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Create a new animal and mint NFT' })
  @ApiResponse({ status: 201, description: 'Animal created and NFT minted successfully', type: AnimalResponseDto })
  async create(
    @Body() createAnimalDto: CreateAnimalDto,
    @Request() req: any,
    @UploadedFile() imageFile?: Express.Multer.File,
  ): Promise<AnimalResponseDto> {
    return this.animalsService.createAnimal(createAnimalDto, req.user.id, imageFile);
  }

  @Get()
  @ApiOperation({ summary: 'Get all animals with pagination' })
  @ApiResponse({ status: 200, description: 'Animals retrieved successfully' })
  async findAll(@Query() paginationDto: PaginationDto, @Query('ownerId') ownerId?: string) {
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

  @Get(':id')
  @ApiOperation({ summary: 'Get animal by ID' })
  @ApiResponse({ status: 200, description: 'Animal retrieved successfully', type: AnimalResponseDto })
  @ApiResponse({ status: 404, description: 'Animal not found' })
  async findOne(@Param('id') id: string): Promise<AnimalResponseDto> {
    return this.animalsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update animal metadata' })
  @ApiResponse({ status: 200, description: 'Animal updated successfully', type: AnimalResponseDto })
  @ApiResponse({ status: 403, description: 'Forbidden - not your animal' })
  @ApiResponse({ status: 404, description: 'Animal not found' })
  async update(
    @Param('id') id: string,
    @Body() updateAnimalDto: UpdateAnimalDto,
    @Request() req: any,
  ): Promise<AnimalResponseDto> {
    return this.animalsService.update(id, updateAnimalDto, req.user.id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete animal and burn NFT' })
  @ApiResponse({ status: 200, description: 'Animal deleted and NFT burned successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not your animal' })
  @ApiResponse({ status: 404, description: 'Animal not found' })
  async remove(@Param('id') id: string, @Request() req: any): Promise<{ message: string }> {
    return this.animalsService.remove(id, req.user.id);
  }

  @Post(':id/upload-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload animal image' })
  @ApiResponse({ status: 200, description: 'Image uploaded successfully', type: AnimalResponseDto })
  async uploadImage(
    @Param('id') id: string,
    @Request() req: any,
    @UploadedFile() imageFile: Express.Multer.File,
  ): Promise<AnimalResponseDto> {
    return this.animalsService.uploadAnimalImage(id, req.user.id, imageFile);
  }

  @Post(':id/upload-vet-record')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('vetRecord'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload vet record' })
  @ApiResponse({ status: 200, description: 'Vet record uploaded successfully', type: AnimalResponseDto })
  async uploadVetRecord(
    @Param('id') id: string,
    @Request() req: any,
    @UploadedFile() vetRecordFile: Express.Multer.File,
  ): Promise<AnimalResponseDto> {
    return this.animalsService.uploadVetRecord(id, req.user.id, vetRecordFile);
  }
}
