import { ApiProperty } from '@nestjs/swagger';
import { IsObject, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class MintNftDto {
  @ApiProperty({
    description: 'NFT metadata object containing animal information',
    example: {
      name: 'Buddy',
      species: 'DOG',
      breed: 'Golden Retriever',
      age: 3,
      health: 'healthy',
      image: 'https://example.com/buddy.jpg',
      vetRecord: 'https://example.com/vet-record.pdf'
    }
  })
  @IsObject()
  @IsNotEmpty()
  metadata: any;

  @ApiProperty({
    description: 'Token ID of the collection to mint into',
    example: '0.0.123456',
    required: false
  })
  @IsString()
  @IsOptional()
  tokenId?: string;
}

export class MintNftResponseDto {
  @ApiProperty({
    description: 'Serial number of the minted NFT',
    example: '12345'
  })
  serialNumber: string;

  @ApiProperty({
    description: 'Transaction hash of the minting transaction',
    example: '0.0.123456@1640995200.000000000'
  })
  transactionHash: string;

  @ApiProperty({
    description: 'Token ID of the collection',
    example: '0.0.123456'
  })
  tokenId: string;

  @ApiProperty({
    description: 'Metadata that was minted with the NFT',
    example: {
      name: 'Buddy',
      species: 'DOG',
      breed: 'Golden Retriever',
      age: 3
    }
  })
  metadata: any;
}
