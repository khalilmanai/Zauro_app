import { ConfigService } from '@nestjs/config';
export declare class EncryptionService {
    private configService;
    private readonly key;
    constructor(configService: ConfigService);
    encrypt(text: string): string;
    decrypt(encryptedText: string): string;
}
