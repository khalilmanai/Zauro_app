import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateCollectionDto {
  @ApiProperty({ example: 'Animals' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ example: 'ANML' })
  @IsString()
  @MaxLength(20)
  symbol: string;

  @ApiPropertyOptional({ example: 'Primary marketplace collection' })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  memo?: string;

  @ApiPropertyOptional({ example: 10000 })
  @IsOptional()
  @IsInt()
  @Min(1)
  maxSupply?: number;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @ApiProperty({ example: 'userId-of-admin' })
  @IsString()
  createdByUserId: string;
}


