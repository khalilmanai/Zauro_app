import { WalletService } from './wallet.service';
import { CreateWalletDto } from './dto/create-wallet.dto';
import { WalletResponseDto } from './dto/wallet-response.dto';
import { TransferHbarDto } from './dto/transfer-hbar.dto';
import { TransferResponseDto } from './dto/transfer-response.dto';
import { BalanceResponseDto } from './dto/balance-response.dto';
import { FundAccountDto } from './dto/fund-account.dto';
export declare class WalletController {
    private readonly walletService;
    constructor(walletService: WalletService);
    createWallet(createWalletDto: CreateWalletDto, req: any): Promise<WalletResponseDto>;
    getMyWallet(req: any): Promise<WalletResponseDto>;
    getMyWalletBalance(req: any): Promise<BalanceResponseDto>;
    transferHbar(transferDto: TransferHbarDto, req: any): Promise<TransferResponseDto>;
    getWallet(id: string): Promise<WalletResponseDto>;
    getWalletBalance(id: string): Promise<BalanceResponseDto>;
    fundMyAccount(fundDto: FundAccountDto, req: any): Promise<TransferResponseDto>;
    fundAccount(fundDto: FundAccountDto): Promise<TransferResponseDto>;
    createWalletWithBalance(fundDto: FundAccountDto, req: any): Promise<WalletResponseDto>;
}
