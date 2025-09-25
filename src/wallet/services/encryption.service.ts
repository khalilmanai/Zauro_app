import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as CryptoJS from 'crypto-js';

@Injectable()
export class EncryptionService {
  private readonly key: string;

  constructor(private configService: ConfigService) {
    this.key = this.configService.get<string>('encryption.key') || 'default-32-character-encryption-key';
    if (!this.key || this.key.length !== 32) {
      throw new Error('ENCRYPTION_KEY must be exactly 32 characters long');
    }
  }

  encrypt(text: string): string {
    const encrypted = CryptoJS.AES.encrypt(text, this.key).toString();
    return encrypted;
  }

  decrypt(encryptedText: string): string {
    const decrypted = CryptoJS.AES.decrypt(encryptedText, this.key);
    return decrypted.toString(CryptoJS.enc.Utf8);
  }
}
