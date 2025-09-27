import { AnimalSpecies } from '@prisma/client';
export declare class CreateAnimalDto {
    name: string;
    species: AnimalSpecies;
    breed?: string;
    age?: number;
    description?: string;
    aiPredictionValue?: number;
}
