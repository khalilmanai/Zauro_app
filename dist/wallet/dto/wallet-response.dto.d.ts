export declare class WalletResponseDto {
    id: string;
    hederaAccountId: string;
    publicKey: string;
    balance: {
        hbar: string;
        zau: string;
    };
    createdAt: Date;
}
