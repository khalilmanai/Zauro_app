import { IsEmail, IsString, IsOptional, IsPhoneNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasswordRequestDto {
  @ApiProperty({
    example: 'john.doe@example.com',
    description: 'User email address (provide either email or phone)',
    required: false
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({
    example: '+1234567890',
    description: 'User phone number (provide either email or phone)',
    required: false
  })
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}

export class VerifyOtpDto {
  @ApiProperty({
    example: '123456',
    description: 'OTP code received via email or SMS'
  })
  @IsString()
  code: string;

  @ApiProperty({
    example: 'john.doe@example.com',
    description: 'User email address (must match the one used for OTP request)',
    required: false
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({
    example: '+1234567890',
    description: 'User phone number (must match the one used for OTP request)',
    required: false
  })
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}

export class ResetPasswordDto {
  @ApiProperty({
    example: '123456',
    description: 'Verified OTP code'
  })
  @IsString()
  code: string;

  @ApiProperty({
    example: 'NewSecurePassword123!',
    description: 'New password for the user account'
  })
  @IsString()
  newPassword: string;

  @ApiProperty({
    example: 'john.doe@example.com',
    description: 'User email address (must match the one used for OTP)',
    required: false
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiProperty({
    example: '+1234567890',
    description: 'User phone number (must match the one used for OTP)',
    required: false
  })
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}
