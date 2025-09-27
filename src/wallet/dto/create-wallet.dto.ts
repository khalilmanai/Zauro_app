import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class CreateWalletDto {
  @ApiPropertyOptional({
    example: 'cm4abc123def456ghi789jkl',
    description: 'User ID for wallet creation (ignored - always uses authenticated user ID)',
    type: String
  })
  @IsOptional()
  @IsString()
  userId?: string;
}
