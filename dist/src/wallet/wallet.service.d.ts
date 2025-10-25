import { PrismaService } from '../prisma/prisma.service';
import { HederaService } from './services/hedera.service';
import { EncryptionService } from './services/encryption.service';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { TransferResponseDto } from './dto/transfer-response.dto';
export declare class WalletService {
    private prisma;
    private hederaService;
    private encryptionService;
    constructor(prisma: PrismaService, hederaService: HederaService, encryptionService: EncryptionService);
    createWallet(userId: string): Promise<WalletResponseDto>;
    getWallet(userId: string): Promise<WalletResponseDto>;
    getWalletBalance(userId: string): Promise<{
        hbar: string;
        zau: string;
    }>;
    transferHbar(userId: string, toAccountId: string, amount: string): Promise<TransferResponseDto>;
    getWalletByAccountId(accountId: string): Promise<({
        user: {
            id: string;
            email: string;
            phone: string | null;
            password: string;
            firstName: string;
            lastName: string;
            role: import("@prisma/client").$Enums.UserRole;
            isActive: boolean;
            isVerified: boolean;
            createdAt: Date;
            updatedAt: Date;
            lastLoginAt: Date | null;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        hederaAccountId: string;
        encryptedPrivateKey: string;
        publicKey: string;
        userId: string;
    }) | null>;
    fundUserAccount(userId: string, amount: string, memo?: string): Promise<TransferResponseDto>;
    fundHederaAccount(accountId: string, amount: string, memo?: string): Promise<TransferResponseDto>;
    createWalletWithBalance(userId: string, initialBalance: string): Promise<WalletResponseDto>;
}
