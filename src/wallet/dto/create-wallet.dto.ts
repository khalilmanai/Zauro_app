import { IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateWalletDto {
  @ApiProperty({
    example: 'cm4abc123def456ghi789jkl',
    description: 'User ID for wallet creation (optional - defaults to authenticated user)',
    required: false
  })
  @IsOptional()
  @IsString()
  userId?: string;
}
