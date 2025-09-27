import { IsString, IsEnum, IsOptional, IsInt, IsDecimal, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { AnimalSpecies } from '@prisma/client';

export class CreateAnimalDto {
  @ApiProperty({
    example: 'Buddy',
    description: 'Name of the animal'
  })
  @IsString()
  name: string;

  @ApiProperty({
    example: 'DOG',
    description: 'Species of the animal',
    enum: AnimalSpecies,
    enumName: 'AnimalSpecies'
  })
  @IsEnum(AnimalSpecies)
  species: AnimalSpecies;

  @ApiProperty({
    example: 'Golden Retriever',
    description: 'Breed of the animal (optional)',
    required: false
  })
  @IsOptional()
  @IsString()
  breed?: string;

  @ApiProperty({
    example: 3,
    description: 'Age of the animal in years (0-50)',
    minimum: 0,
    maximum: 50,
    required: false
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(50)
  age?: number;

  @ApiProperty({
    example: 'Friendly and energetic dog, great with children and other pets. Fully house trained and loves outdoor activities.',
    description: 'Detailed description of the animal (optional)',
    required: false
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    example: 1500.50,
    description: 'AI-predicted market value of the animal in HBAR (optional)',
    required: false
  })
  @IsOptional()
  @IsDecimal()
  aiPredictionValue?: number;
}
