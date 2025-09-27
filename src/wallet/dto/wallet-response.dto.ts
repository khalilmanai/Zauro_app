import { ApiProperty } from '@nestjs/swagger';

export class BalanceDto {
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

export class WalletResponseDto {
  @ApiProperty({
    example: 'cm4abc123def456ghi789jkl',
    description: 'Unique wallet identifier'
  })
  id: string;

  @ApiProperty({
    example: '0.0.123456',
    description: 'Hedera account ID associated with this wallet'
  })
  hederaAccountId: string;

  @ApiProperty({
    example: '302a300506032b65700321004f2b8c8d...',
    description: 'Public key of the Hedera account'
  })
  publicKey: string;

  @ApiProperty({
    type: BalanceDto,
    description: 'Current wallet balance'
  })
  balance: BalanceDto;

  @ApiProperty({
    example: '2024-09-27T10:30:00.000Z',
    description: 'Wallet creation timestamp'
  })
  createdAt: Date;
}
