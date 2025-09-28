import { HederaService } from '../services/hedera.service';
export declare class HederaServiceExample {
    private readonly hederaService;
    private readonly logger;
    constructor(hederaService: HederaService);
    createAccountExample(): Promise<any>;
    fundAccountExample(accountId: string, amount: string): Promise<void>;
    checkBalanceExample(accountId: string): Promise<void>;
    generateKeypairExample(): void;
    getServiceInfoExample(): void;
    private verifyAccountBalance;
    errorHandlingExample(): Promise<void>;
}
