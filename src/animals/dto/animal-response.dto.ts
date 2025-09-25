import { AnimalSpecies } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

export class AnimalResponseDto {
  id: string;
  name: string;
  species: AnimalSpecies;
  breed?: string | null;
  age?: number | null;
  description?: string | null;
  tokenId?: string | null;
  tokenSerialNumber?: string | null;
  imageUrl?: string | null;
  vetRecordUrl?: string | null;
  aiPredictionValue?: Decimal | null;
  ownerId: string;
  isListed: boolean;
  createdAt: Date;
  updatedAt: Date;
  owner: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
}
