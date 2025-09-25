import { IsString, IsDecimal, IsOptional, Min } from 'class-validator';

export class CreateTradeDto {
  @IsString()
  animalId: string;

  @IsDecimal()
  @Min(0)
  price: number;

  @IsOptional()
  @IsString()
  currency?: string = 'HBAR';
}
