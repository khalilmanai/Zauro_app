import { IsString, IsDecimal, IsOptional, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTradeDto {
  @ApiProperty({
    example: 'cm4abc123def456ghi789jkl',
    description: 'ID of the animal to list for trade'
  })
  @IsString()
  animalId: string;

  @ApiProperty({
    example: 100.50,
    description: 'Price for the animal trade',
    minimum: 0
  })
  @IsDecimal()
  @Min(0)
  price: number;

  @ApiProperty({
    example: 'HBAR',
    description: 'Currency for the trade (HBAR or ZAU)',
    default: 'HBAR',
    required: false
  })
  @IsOptional()
  @IsString()
  currency?: string = 'HBAR';
}
