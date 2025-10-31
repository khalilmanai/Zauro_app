import { ApiProperty } from '@nestjs/swagger';

export class BalanceResponseDto {
  @ApiProperty({
    example: '10 ℏ',
    description: 'HBAR balance in the account'
  })
  hbar: string;

  @ApiProperty({
    example: '0',
    description: 'ZAU token balance in the account'
  })
  zau: string;

  @ApiProperty({
    example: {},
    description: 'Other token balances in the account'
  })
  tokens: Record<string, string>;

  @ApiProperty({
    example: '2025-10-30T16:37:10.973Z',
    description: 'Timestamp of the balance query'
  })
  timestamp: string;
}
