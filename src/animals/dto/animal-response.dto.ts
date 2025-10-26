import { AnimalSpecies, AnimalGender, AnimalStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

export class AnimalResponseDto {
  id: string;
  name: string;
  species: AnimalSpecies;
  breed?: string | null;
  age?: number | null;
  gender: AnimalGender;
  description?: string | null;
  tokenId?: string | null;
  tokenSerialNumber?: string | null;
  imageUrl?: string | null;
  vetRecordUrl?: string | null;
  aiPredictionValue?: Decimal | null;
  ownerId: string;
  isListed: boolean;
  status: AnimalStatus;
  expertReviewedBy?: string | null;
  expertReviewComment?: string | null;
  expertReviewDate?: Date | null;
  createdAt: Date;
  updatedAt: Date;
  owner: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
}
