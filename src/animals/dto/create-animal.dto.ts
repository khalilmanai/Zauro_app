import { IsString, IsEnum, IsOptional, IsInt, IsDecimal, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { AnimalSpecies, AnimalGender } from '@prisma/client';

export class CreateAnimalDto {
  @ApiProperty({
    example: 'Bella',
    description: 'Name of the animal'
  })
  @IsString()
  name: string;

  @ApiProperty({
    example: 'COW',
    description: 'Species of the animal',
    enum: AnimalSpecies,
    enumName: 'AnimalSpecies'
  })
  @IsEnum(AnimalSpecies)
  species: AnimalSpecies;

  @ApiProperty({
    example: 'Holstein Friesian',
    description: 'Breed of the animal (optional)',
    required: false
  })
  @IsOptional()
  @IsString()
  breed?: string;

  @ApiProperty({
    example: 'FEMALE',
    description: 'Gender of the animal',
    enum: AnimalGender,
    enumName: 'AnimalGender'
  })
  @IsEnum(AnimalGender)
  gender: AnimalGender;

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
    example: 'Healthy cow with excellent milk production. Vaccinated and well-fed. Good temperament and adapts well to different farm conditions.',
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
