import { ApiProperty } from '@nestjs/swagger';

export class BalanceDto {
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

export class WalletResponseDto {
  @ApiProperty({
    example: 'cmhckvxhr0004ph01tpc57tw5',
    description: 'Unique wallet identifier'
  })
  id: string;

  @ApiProperty({
    example: '0.0.7158765',
    description: 'Hedera account ID associated with this wallet'
  })
  hederaAccountId: string;

  @ApiProperty({
    example: '302a300506032b65700321000d39111e81f9c55fe677a305b86cfbbaacd136c0b2b5ef59887b16ac89bbfcc0',
    description: 'Public key of the Hedera account'
  })
  publicKey: string;

  @ApiProperty({
    type: BalanceDto,
    description: 'Current wallet balance'
  })
  balance: BalanceDto;

  @ApiProperty({
    example: '2025-10-29T22:39:45.999Z',
    description: 'Wallet creation timestamp'
  })
  createdAt: Date;
}
