import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsNumber } from 'class-validator';

export class CreateCollectionDto {
  @ApiProperty({
    description: 'Name of the NFT collection',
    example: 'Zauro Animals Collection'
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Symbol of the NFT collection',
    example: 'ZAC'
  })
  @IsString()
  @IsNotEmpty()
  symbol: string;

  @ApiProperty({
    description: 'Maximum supply of NFTs in this collection',
    example: 1000000,
    required: false
  })
  @IsNumber()
  @IsOptional()
  maxSupply?: number;
}

export class CollectionResponseDto {
  @ApiProperty({
    description: 'Token ID of the created collection',
    example: '0.0.123456'
  })
  tokenId: string;

  @ApiProperty({
    description: 'Supply key for minting NFTs in this collection',
    example: '302e020100300506032b657004220420...'
  })
  supplyKey: string;

  @ApiProperty({
    description: 'Name of the collection',
    example: 'Zauro Animals Collection'
  })
  name: string;

  @ApiProperty({
    description: 'Symbol of the collection',
    example: 'ZAC'
  })
  symbol: string;

  @ApiProperty({
    description: 'Maximum supply of NFTs',
    example: 1000000
  })
  maxSupply: number;
}

export class CollectionStatusDto {
  @ApiProperty({
    description: 'Token ID of the collection',
    example: '0.0.123456'
  })
  tokenId: string;

  @ApiProperty({
    description: 'Name of the collection',
    example: 'Zauro Animals Collection'
  })
  name: string;

  @ApiProperty({
    description: 'Symbol of the collection',
    example: 'ZAC'
  })
  symbol: string;

  @ApiProperty({
    description: 'Current number of NFTs minted',
    example: 150
  })
  nftCount: number;

  @ApiProperty({
    description: 'Maximum supply of NFTs',
    example: 1000000
  })
  maxSupply: number;

  @ApiProperty({
    description: 'Usage percentage of the collection',
    example: 0.015
  })
  usagePercentage: number;

  @ApiProperty({
    description: 'Status of the collection',
    example: 'ACTIVE',
    enum: ['ACTIVE', 'NEAR_LIMIT', 'FULL']
  })
  status: string;
}
