export interface AccountCreationResult {
    accountId: string;
    privateKey: string;
    publicKey: string;
    transactionId: string;
    initialBalance: string;
}
export interface AccountBalance {
    hbar: string;
    zau: string;
    tokens?: Record<string, string>;
    timestamp: Date;
}
export interface FundingResult {
    transactionId: string;
    fromAccountId: string;
    toAccountId: string;
    amount: string;
    memo?: string;
    timestamp: Date;
}
export interface HederaConfig {
    accountId: string;
    privateKey: string;
    network: 'testnet' | 'previewnet' | 'mainnet';
    mirrorNodeUrl?: string;
}
export interface CreateAccountOptions {
    initialBalance?: number;
    memo?: string;
    maxTransactionFee?: number;
}
export interface FundingOptions {
    memo?: string;
    maxTransactionFee?: number;
}
export interface ValidationResult {
    isValid: boolean;
    error?: string;
}
export interface NetworkInfo {
    name: string;
    explorerUrl: string;
    mirrorNodeUrl: string;
}
export interface HashScanUrls {
    accountUrl: string;
    transactionUrl?: string;
}
