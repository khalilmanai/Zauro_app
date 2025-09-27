import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class TransferNftDto {
  @ApiProperty({
    description: 'Token ID of the NFT collection',
    example: '0.0.123456'
  })
  @IsString()
  @IsNotEmpty()
  tokenId: string;

  @ApiProperty({
    description: 'Serial number of the NFT to transfer',
    example: '12345'
  })
  @IsString()
  @IsNotEmpty()
  serialNumber: string;

  @ApiProperty({
    description: 'Hedera account ID of the recipient',
    example: '0.0.789012'
  })
  @IsString()
  @IsNotEmpty()
  toAccountId: string;
}

export class TransferNftResponseDto {
  @ApiProperty({
    description: 'Transaction hash of the transfer',
    example: '0.0.123456@1640995200.000000000'
  })
  transactionHash: string;

  @ApiProperty({
    description: 'Success status of the transfer',
    example: true
  })
  success: boolean;
}
