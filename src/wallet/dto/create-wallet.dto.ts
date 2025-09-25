import { IsOptional, IsString } from 'class-validator';

export class CreateWalletDto {
  @IsOptional()
  @IsString()
  userId?: string;
}
