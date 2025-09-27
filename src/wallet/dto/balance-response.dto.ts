import { ApiProperty } from '@nestjs/swagger';

export class BalanceResponseDto {
  @ApiProperty({
    example: '100.12345678',
    description: 'HBAR balance in the account'
  })
  hbar: string;

  @ApiProperty({
    example: '1000.50',
    description: 'ZAU token balance in the account'
  })
  zau: string;
}
