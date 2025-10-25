import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CollectionsService } from './collections.service';
import { Roles } from '../common/decorators/roles.decorator';
import { CreateCollectionDto } from './dto/create-collection.dto';

@ApiTags('Collections')
@ApiBearerAuth('JWT-auth')
@Controller('admin/collections')
export class CollectionsController {
  constructor(private readonly service: CollectionsService) {}

  @Post()
  @Roles('ADMIN', 'HR_MANAGER')
  @ApiOperation({ summary: 'Create NFT collection (HTS token)', description: 'Admin-only. Creates an NFT collection on Hedera and stores it in DB.' })
  async create(@Body() body: CreateCollectionDto) {
    return this.service.createCollection({
      name: body.name,
      symbol: body.symbol,
      memo: body.memo,
      maxSupply: body.maxSupply,
      setDefault: body.isDefault,
    });
  }

  @Get()
  @Roles('ADMIN', 'HR_MANAGER')
  @ApiOperation({ summary: 'List all collections' })
  async list() {
    return this.service.listCollections();
  }

  @Get('default')
  @ApiOperation({ summary: 'Get default active collection (used by user mints)' })
  async getDefault() {
    return this.service.getDefaultCollection();
  }

  @Post('rotate-if-full')
  @Roles('ADMIN', 'HR_MANAGER')
  @ApiOperation({ summary: 'Check default collection and rotate (create new) if full' })
  async rotateIfFull(@Body() body: { namePrefix?: string; symbolPrefix?: string; memo?: string; }) {
    return this.service.getOrRotateDefaultForMint({
      namePrefix: body.namePrefix,
      symbolPrefix: body.symbolPrefix,
      memo: body.memo,
    });
  }

  @Patch(':id/disable')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Disable a collection' })
  async disable(@Param('id') id: string) {
    return this.service.disableCollection(id);
  }

  @Patch(':id/default')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Set collection as default' })
  async setDefault(@Param('id') id: string) {
    return this.service.setDefault(id);
  }
}


