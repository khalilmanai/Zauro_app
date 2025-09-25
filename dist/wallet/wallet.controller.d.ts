import { WalletService } from './wallet.service';
import { WalletResponseDto } from './dto/wallet-response.dto';
export declare class WalletController {
    private readonly walletService;
    constructor(walletService: WalletService);
    createWallet(req: any): Promise<WalletResponseDto>;
    getMyWallet(req: any): Promise<WalletResponseDto>;
    getMyWalletBalance(req: any): Promise<{
        hbar: string;
        zau: string;
    }>;
    getWallet(id: string): Promise<WalletResponseDto>;
    getWalletBalance(id: string): Promise<{
        hbar: string;
        zau: string;
    }>;
}
