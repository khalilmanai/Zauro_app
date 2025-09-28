import { ConfigService } from '@nestjs/config';
import { PrivateKey } from '@hashgraph/sdk';
import { AccountCreationResult, AccountBalance, FundingResult, CreateAccountOptions, FundingOptions, ValidationResult, NetworkInfo, HashScanUrls } from '../interfaces/hedera.interfaces';
export declare class HederaService {
    private configService;
    private readonly logger;
    private client;
    private readonly networkInfo;
    private readonly operatorAccountId;
    private readonly operatorPrivateKey;
    constructor(configService: ConfigService);
    private validateAndGetConfig;
    private initializeClient;
    private createNetworkInfo;
    generateKeyPair(): {
        privateKey: PrivateKey;
        publicKey: string;
    };
    createAccount(options?: CreateAccountOptions): Promise<AccountCreationResult>;
    getAccountBalance(accountId: string): Promise<AccountBalance>;
    transferHbar(fromAccountId: string, toAccountId: string, amount: string, privateKey: string): Promise<string>;
    mintNft(tokenId: string, metadata: string, privateKey: string): Promise<{
        serialNumber: string;
        transactionHash: string;
    }>;
    burnNft(tokenId: string, serialNumber: string, privateKey: string): Promise<string>;
    fundAccount(targetAccountId: string, amount: string, options?: FundingOptions): Promise<FundingResult>;
    initializeAccountWithBalance(initialBalance: string): Promise<{
        accountId: string;
        privateKey: string;
        publicKey: string;
        fundingTransactionId: string;
    }>;
    private validateAccountId;
    private validateAmount;
    getHashScanUrls(accountId: string, transactionId?: string): HashScanUrls;
    getNetworkInfo(): NetworkInfo;
    getOperatorInfo(): {
        accountId: string;
        network: string;
    };
    validateOperatorBalance(requiredAmount: number): Promise<ValidationResult>;
}
