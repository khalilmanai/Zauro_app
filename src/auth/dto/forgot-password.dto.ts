import { IsEmail, IsString, IsOptional, IsPhoneNumber } from 'class-validator';

export class ForgotPasswordRequestDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}

export class VerifyOtpDto {
  @IsString()
  code: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}

export class ResetPasswordDto {
  @IsString()
  code: string;

  @IsString()
  newPassword: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}
