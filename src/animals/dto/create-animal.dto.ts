import { IsString, IsEnum, IsOptional, IsInt, IsDecimal, Min, Max } from 'class-validator';
import { AnimalSpecies } from '@prisma/client';

export class CreateAnimalDto {
  @IsString()
  name: string;

  @IsEnum(AnimalSpecies)
  species: AnimalSpecies;

  @IsOptional()
  @IsString()
  breed?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(50)
  age?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsDecimal()
  aiPredictionValue?: number;
}
