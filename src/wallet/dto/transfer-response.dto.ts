import { ApiProperty } from '@nestjs/swagger';

export class TransferResponseDto {
  @ApiProperty({
    example: '0.0.123456@1695804600.123456789',
    description: 'Hedera transaction hash/ID'
  })
  transactionHash: string;
}
