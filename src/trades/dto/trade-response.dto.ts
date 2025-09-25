import { TradeStatus } from '@prisma/client';
import { Decimal } from '@prisma/client/runtime/library';

export class TradeResponseDto {
  id: string;
  animalId: string;
  sellerId: string;
  buyerId?: string | null;
  price: Decimal;
  currency: string;
  status: TradeStatus;
  contractAddress?: string | null;
  transactionHash?: string | null;
  createdAt: Date;
  updatedAt: Date;
  completedAt?: Date | null;
  animal: {
    id: string;
    name: string;
    species: string;
    imageUrl?: string | null;
    owner: {
      id: string;
      firstName: string;
      lastName: string;
    };
  };
  seller: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
  buyer?: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  } | null;
}
