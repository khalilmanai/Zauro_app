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
  Put,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
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
  @ApiBearerAuth('JWT-auth')
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Create a new animal (pending expert review)' })
  @ApiResponse({ status: 201, description: 'Animal created and awaiting expert review', type: AnimalResponseDto })
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
  async findAll(@Query() paginationDto: PaginationDto) {
    const result = await this.animalsService.findAll(paginationDto);
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

  @Get('listed')
  @ApiOperation({ summary: 'Get all listed animals with pagination' })
  @ApiResponse({ status: 200, description: 'Listed animals retrieved successfully' })
  async getAllListed(@Query() paginationDto: PaginationDto) {
    const result = await this.animalsService.findAllListed(paginationDto);
    return {
      success: true,
      message: 'Listed animals retrieved successfully',
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

  @Get('unlisted')
  @ApiOperation({ summary: 'Get all unlisted animals with pagination' })
  @ApiResponse({ status: 200, description: 'Unlisted animals retrieved successfully' })
  async getAllUnlisted(@Query() paginationDto: PaginationDto) {
    const result = await this.animalsService.findAllUnlisted(paginationDto);
    return {
      success: true,
      message: 'Unlisted animals retrieved successfully',
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

  @Get('my')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Get my animals with pagination' })
  @ApiResponse({ status: 200, description: 'User animals retrieved successfully' })
  async findMine(@Query() paginationDto: PaginationDto, @Request() req: any) {
    const result = await this.animalsService.findAllByOwnerId(paginationDto, req.user.id);
    return {
      success: true,
      message: 'User animals retrieved successfully',
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

  @Get('pending-review')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Get animals pending expert review (Admin/Manager only)' })
  @ApiResponse({ status: 200, description: 'Pending review animals retrieved successfully' })
  async getPendingReview(@Query() paginationDto: PaginationDto) {
    const result = await this.animalsService.getPendingReviewAnimals(paginationDto);
    return {
      success: true,
      message: 'Pending review animals retrieved successfully',
      data: result.animals,
      pagination: {
        page: result.page,
        limit: result.limit,
        total: result.total,
        totalPages: result.totalPages,
      },
    };
  }

  @Put(':id/review')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Review an animal (approve/reject) - Admin/Manager only' })
  @ApiResponse({ status: 200, description: 'Animal reviewed successfully', type: AnimalResponseDto })
  @ApiBody({
    description: 'Review decision',
    schema: {
      type: 'object',
      required: ['approved'],
      properties: {
        approved: { type: 'boolean' },
        comment: { type: 'string' },
      },
    },
    examples: {
      approve: { value: { approved: true, comment: 'Looks good' } },
      reject: { value: { approved: false, comment: 'Missing records' } },
    },
  })
  async reviewAnimal(
    @Param('id') id: string,
    @Request() req: any,
    @Body() reviewDto: { approved: boolean; comment?: string },
  ): Promise<AnimalResponseDto> {
    if (!reviewDto || typeof reviewDto.approved !== 'boolean') {
      throw new BadRequestException('Request body must include boolean "approved". Optional "comment" may be provided.');
    }
    return this.animalsService.reviewAnimal(id, req.user.id, reviewDto.approved, reviewDto.comment);
  }

  @Post(':id/mint')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Mint NFT after expert approval' })
  @ApiResponse({ status: 201, description: 'NFT minted successfully', type: AnimalResponseDto })
  async mintAnimal(
    @Param('id') id: string,
    @Request() req: any,
  ): Promise<AnimalResponseDto> {
    return this.animalsService.mintAnimal(id, req.user.id);
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
  @ApiBearerAuth('JWT-auth')
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
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Delete animal and burn NFT' })
  @ApiResponse({ status: 200, description: 'Animal deleted and NFT burned successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not your animal' })
  @ApiResponse({ status: 404, description: 'Animal not found' })
  async remove(@Param('id') id: string, @Request() req: any): Promise<{ message: string }> {
    return this.animalsService.remove(id, req.user.id);
  }

  @Post(':id/upload-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
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
  @ApiBearerAuth('JWT-auth')
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
