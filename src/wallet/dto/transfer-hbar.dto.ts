import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class TransferHbarDto {
  @ApiProperty({
    example: '0.0.654321',
    description: 'Destination Hedera account ID',
    pattern: '^0\\.0\\.[0-9]+$'
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^0\.0\.[0-9]+$/, {
    message: 'toAccountId must be a valid Hedera account ID format (0.0.123456)'
  })
  toAccountId: string;

  @ApiProperty({
    example: '10.5',
    description: 'Amount of HBAR to transfer (in HBAR, not tinybars)',
    pattern: '^[0-9]+(\\.[0-9]+)?$'
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^[0-9]+(\.[0-9]+)?$/, {
    message: 'amount must be a valid positive number'
  })
  amount: string;
}
