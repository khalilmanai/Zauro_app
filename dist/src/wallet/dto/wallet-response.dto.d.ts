export declare class BalanceDto {
    hbar: string;
    zau: string;
}
export declare class WalletResponseDto {
    id: string;
    hederaAccountId: string;
    publicKey: string;
    balance: BalanceDto;
    createdAt: Date;
}
