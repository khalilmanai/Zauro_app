import { ConfigService } from '@nestjs/config';
export declare class HederaService {
    private configService;
    private readonly logger;
    private client;
    constructor(configService: ConfigService);
    private initializeClient;
    createAccount(): Promise<{
        accountId: string;
        privateKey: string;
        publicKey: string;
    }>;
    getAccountBalance(accountId: string): Promise<{
        hbar: string;
        zau: string;
    }>;
    transferHbar(fromAccountId: string, toAccountId: string, amount: string, privateKey: string): Promise<string>;
    mintNft(tokenId: string, metadata: string, privateKey: string): Promise<{
        serialNumber: string;
        transactionHash: string;
    }>;
    burnNft(tokenId: string, serialNumber: string, privateKey: string): Promise<string>;
}
