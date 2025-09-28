import { IsString, IsNotEmpty, Matches, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class FundAccountDto {
  @ApiProperty({
    example: '50.0',
    description: 'Amount of HBAR to fund the account with (in HBAR, not tinybars)',
    pattern: '^[0-9]+(\\.[0-9]+)?$'
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^[0-9]+(\.[0-9]+)?$/, {
    message: 'amount must be a valid positive number'
  })
  amount: string;

  @ApiProperty({
    example: '0.0.654321',
    description: 'Target Hedera account ID to fund (optional - defaults to user\'s wallet)',
    pattern: '^0\\.0\\.[0-9]+$',
    required: false
  })
  @IsOptional()
  @IsString()
  @Matches(/^0\.0\.[0-9]+$/, {
    message: 'accountId must be a valid Hedera account ID format (0.0.123456)'
  })
  accountId?: string;

  @ApiProperty({
    example: 'Initial funding for new user account',
    description: 'Optional memo/note for the funding transaction',
    required: false
  })
  @IsOptional()
  @IsString()
  memo?: string;
}
