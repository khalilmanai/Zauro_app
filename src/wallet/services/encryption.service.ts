import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as CryptoJS from 'crypto-js';

@Injectable()
export class EncryptionService {
  private readonly key: string;

  constructor(private configService: ConfigService) {
    const encryptionKey = this.configService.get<string>('encryption.key');
    if (!encryptionKey) {
      throw new Error('ENCRYPTION_KEY must be configured in environment variables');
    }
    if (encryptionKey.length !== 32) {
      throw new Error('ENCRYPTION_KEY must be exactly 32 characters long');
    }
    this.key = encryptionKey;
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
