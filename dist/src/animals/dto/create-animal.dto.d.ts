import { AnimalSpecies, AnimalGender } from '@prisma/client';
export declare class CreateAnimalDto {
    name: string;
    species: AnimalSpecies;
    breed?: string;
    gender: AnimalGender;
    age?: number;
    description?: string;
    aiPredictionValue?: number;
}
