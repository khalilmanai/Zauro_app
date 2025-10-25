import { Injectable, Logger, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  Client,
  PrivateKey,
  AccountId,
  AccountBalanceQuery,
  TokenId,
  AccountCreateTransaction,
  TransferTransaction,
  TokenMintTransaction,
  TokenBurnTransaction,
  TokenAssociateTransaction,
  TokenType,
  TokenSupplyType,
  TokenCreateTransaction,
  TokenInfoQuery,
  Hbar,
  Status,
  TransactionResponse,
  TransactionReceipt,
} from '@hashgraph/sdk';
import {
  AccountCreationResult,
  AccountBalance,
  FundingResult,
  HederaConfig,
  CreateAccountOptions,
  FundingOptions,
  ValidationResult,
  NetworkInfo,
  HashScanUrls,
} from '../interfaces/hedera.interfaces';

@Injectable()
export class HederaService {
  private readonly logger = new Logger(HederaService.name);
  private client: Client;
  private readonly networkInfo: NetworkInfo;
  private readonly operatorAccountId: AccountId;
  private readonly operatorPrivateKey: PrivateKey;

  constructor(private configService: ConfigService) {
    const config = this.validateAndGetConfig();
    this.networkInfo = this.createNetworkInfo(config.network);
    this.operatorAccountId = AccountId.fromString(config.accountId);
    this.operatorPrivateKey = PrivateKey.fromString(config.privateKey);
    this.initializeClient(config);
  }

  /** Get token total supply and max supply (if finite) */
  async getTokenInfo(tokenId: string): Promise<{ totalSupply: number; maxSupply?: number }> {
    try {
      const info = await new TokenInfoQuery().setTokenId(TokenId.fromString(tokenId)).execute(this.client);
      const totalSupply = Number(info.totalSupply?.toString?.() || info.totalSupply);
      const maxSupply = info.maxSupply != null ? Number(info.maxSupply) : undefined;
      return { totalSupply, maxSupply };
    } catch (error) {
      this.logger.error('Failed to get token info:', error);
      throw new InternalServerErrorException(`Token info failed: ${error.message}`);
    }
  }

  /**
   * Creates a new Hedera NFT collection (HTS token)
   * Returns tokenId and transactionId. Requires operator to have admin & supply capabilities.
   */
  async createNftCollection(params: {
    name: string;
    symbol: string;
    treasuryAccountId?: string; // default operator account
    memo?: string;
    maxSupply?: number; // optional; if provided, sets finite supply
  }): Promise<{ tokenId: string; transactionId: string }> {
    const { name, symbol, treasuryAccountId, memo, maxSupply } = params;

    try {
      const treasury = AccountId.fromString(
        treasuryAccountId || this.operatorAccountId.toString(),
      );

      const tx = new TokenCreateTransaction()
        .setTokenName(name)
        .setTokenSymbol(symbol)
        .setTokenType(TokenType.NonFungibleUnique)
        .setTreasuryAccountId(treasury)
        .setSupplyKey(this.operatorPrivateKey)
        .setAdminKey(this.operatorPrivateKey)
        .setFreezeDefault(false)
        .setMaxTransactionFee(new Hbar(10));

      if (memo) {
        tx.setTokenMemo(memo);
      }

      if (typeof maxSupply === 'number' && maxSupply > 0) {
        tx.setSupplyType(TokenSupplyType.Finite).setMaxSupply(maxSupply);
      } else {
        tx.setSupplyType(TokenSupplyType.Infinite);
      }

      // Don't freeze - let the client handle timing
      const resp = await tx.execute(this.client);
      const receipt = await resp.getReceipt(this.client);

      if (!receipt.tokenId) {
        throw new Error('Token creation failed - no token ID in receipt');
      }

      const tokenId = receipt.tokenId.toString();
      const transactionId = resp.transactionId.toString();

      this.logger.log(`Created NFT collection ${name} (${symbol}) → ${tokenId}`);

      return { tokenId, transactionId };
    } catch (error) {
      this.logger.error('Failed to create NFT collection:', error);
      throw new InternalServerErrorException(`Token creation failed: ${error.message}`);
    }
  }

  /**
   * Validates and retrieves Hedera configuration from environment
   */
  private validateAndGetConfig(): HederaConfig {
    const accountId = this.configService.get<string>('hedera.accountId');
    const privateKey = this.configService.get<string>('hedera.privateKey');
    const network = this.configService.get<string>('hedera.network', 'testnet') as 'testnet' | 'previewnet' | 'mainnet';
    const mirrorNodeUrl = this.configService.get<string>('hedera.mirrorNodeUrl');

    if (!accountId || !privateKey) {
      throw new InternalServerErrorException(
        'Hedera configuration is incomplete. HEDERA_ACCOUNT_ID and HEDERA_PRIVATE_KEY must be set.'
      );
    }

    // Validate account ID format
    const accountIdValidation = this.validateAccountId(accountId);
    if (!accountIdValidation.isValid) {
      throw new InternalServerErrorException(`Invalid HEDERA_ACCOUNT_ID format: ${accountIdValidation.error}`);
    }

    // Validate private key format
    try {
      PrivateKey.fromString(privateKey);
    } catch (error) {
      throw new InternalServerErrorException('Invalid HEDERA_PRIVATE_KEY format');
    }

    return { accountId, privateKey, network, mirrorNodeUrl };
  }

  /**
   * Initializes the Hedera client with proper configuration
   */
  private initializeClient(config: HederaConfig): void {
    try {
      this.client = Client.forName(config.network);
      this.client.setOperator(this.operatorAccountId, this.operatorPrivateKey);
      
      // Set default transaction fee if needed
      this.client.setDefaultMaxTransactionFee(new Hbar(2));
      
      // Set request timeout to handle network delays
      this.client.setRequestTimeout(30000); // 30 seconds
      
      this.logger.log(`Hedera client initialized for ${config.network} network with operator ${config.accountId}`);
    } catch (error) {
      throw new InternalServerErrorException(`Failed to initialize Hedera client: ${error.message}`);
    }
  }

  /**
   * Gets network-specific information
   */
  private createNetworkInfo(network: string): NetworkInfo {
    const networkConfigs: Record<string, NetworkInfo> = {
      testnet: {
        name: 'Hedera Testnet',
        explorerUrl: 'https://hashscan.io/testnet',
        mirrorNodeUrl: 'https://testnet.mirrornode.hedera.com',
      },
      previewnet: {
        name: 'Hedera Previewnet',
        explorerUrl: 'https://hashscan.io/previewnet',
        mirrorNodeUrl: 'https://previewnet.mirrornode.hedera.com',
      },
      mainnet: {
        name: 'Hedera Mainnet',
        explorerUrl: 'https://hashscan.io/mainnet',
        mirrorNodeUrl: 'https://mainnet.mirrornode.hedera.com',
      },
    };

    return networkConfigs[network] || networkConfigs.testnet;
  }

  /**
   * Generates a new ED25519 keypair for Hedera accounts
   * @returns Object containing the generated private and public keys
   */
  generateKeyPair(): { privateKey: PrivateKey; publicKey: string } {
    try {
      const privateKey = PrivateKey.generateED25519();
      const publicKey = privateKey.publicKey.toString();
      
      this.logger.debug('Generated new ED25519 keypair');
      
      return {
        privateKey,
        publicKey,
      };
    } catch (error) {
      this.logger.error('Failed to generate keypair:', error);
      throw new InternalServerErrorException('Failed to generate cryptographic keys');
    }
  }

  /**
   * Creates a new Hedera account using the operator account for funding
   * @param options Configuration options for account creation
   * @returns Promise resolving to account creation details
   */
  async createAccount(options: CreateAccountOptions = {}): Promise<AccountCreationResult> {
    const {
      initialBalance = 10,
      memo,
      maxTransactionFee = 2,
    } = options;

    try {
      // Generate new keypair
      const { privateKey: newPrivateKey, publicKey } = this.generateKeyPair();
      const initialBalanceHbar = new Hbar(initialBalance);
      
      this.logger.log(`Creating new Hedera account with ${initialBalance} HBAR initial balance`);
      
      // ⚠️ SECURITY WARNING: This is a CUSTODIAL approach!
      // The backend generates and stores private keys, making it responsible for wallet security.
      // Consider implementing non-custodial flows where users manage their own keys.
      
      // Create account transaction
      const transaction = new AccountCreateTransaction()
        .setKey(newPrivateKey.publicKey)
        .setInitialBalance(initialBalanceHbar)
        .setMaxTransactionFee(new Hbar(maxTransactionFee));

      // Add memo if provided
      if (memo) {
        transaction.setAccountMemo(memo);
      }

      // Freeze and execute transaction
      const frozenTransaction = transaction.freezeWith(this.client);
      const response: TransactionResponse = await frozenTransaction.execute(this.client);
      const receipt: TransactionReceipt = await response.getReceipt(this.client);
      
      // Validate transaction success
      if (receipt.status !== Status.Success) {
        throw new Error(`Account creation failed with status: ${receipt.status.toString()}`);
      }

      if (!receipt.accountId) {
        throw new Error('Account creation failed - no account ID returned in receipt');
      }

      const newAccountId = receipt.accountId.toString();
      const transactionId = response.transactionId.toString();
      
      this.logger.log(
        `Successfully created Hedera account: ${newAccountId} with transaction ID: ${transactionId}`
      );
      
      return {
        accountId: newAccountId,
        privateKey: newPrivateKey.toString(),
        publicKey,
        transactionId,
        initialBalance: initialBalance.toString(),
      };
    } catch (error) {
      this.logger.error('Failed to create Hedera account:', error);
      
      if (error.message?.includes('INSUFFICIENT_PAYER_BALANCE')) {
        throw new BadRequestException('Operator account has insufficient balance to create new account');
      }
      
      if (error.message?.includes('INVALID_ACCOUNT_ID')) {
        throw new BadRequestException('Invalid account configuration');
      }
      
      throw new InternalServerErrorException(`Account creation failed: ${error.message}`);
    }
  }

  /**
   * Retrieves the balance for a specific Hedera account
   * @param accountId The account ID to query (e.g., "0.0.123456")
   * @returns Promise resolving to account balance information
   */
  async getAccountBalance(accountId: string): Promise<AccountBalance> {
    // Validate account ID format
    const validation = this.validateAccountId(accountId);
    if (!validation.isValid) {
      throw new BadRequestException(`Invalid account ID format: ${validation.error}`);
    }

    try {
      const parsedAccountId = AccountId.fromString(accountId);
      const query = new AccountBalanceQuery().setAccountId(parsedAccountId);
      const balance = await query.execute(this.client);

      // Get HBAR balance
      const hbarBalance = balance.hbars.toString();
      this.logger.debug(`Retrieved HBAR balance for ${accountId}: ${hbarBalance}`);

      // Get ZAU token balance (if configured)
      let zauBalance = '0';
      const zauTokenId = this.configService.get<string>('hedera.zauTokenId');
      
      if (zauTokenId) {
        try {
          const tokenId = TokenId.fromString(zauTokenId);
          const tokenBalance = balance.tokens?.get(tokenId);
          if (tokenBalance) {
            zauBalance = tokenBalance.toString();
          }
        } catch (error) {
          this.logger.warn(`Failed to get ZAU token balance: ${error.message}`);
        }
      }

      // Get all other token balances
      const tokens: Record<string, string> = {};
      if (balance.tokens) {
        // TokenBalanceMap is a Map-like structure
        for (const [tokenId, tokenBalance] of balance.tokens) {
          tokens[tokenId.toString()] = tokenBalance.toString();
        }
      }

      return {
        hbar: hbarBalance,
        zau: zauBalance,
        tokens,
        timestamp: new Date(),
      };
    } catch (error) {
      this.logger.error(`Failed to get balance for account ${accountId}:`, error);
      
      if (error.message?.includes('INVALID_ACCOUNT_ID')) {
        throw new BadRequestException(`Account ${accountId} does not exist`);
      }
      
      throw new InternalServerErrorException(`Failed to retrieve account balance: ${error.message}`);
    }
  }

  async transferHbar(fromAccountId: string, toAccountId: string, amount: string, privateKey: string): Promise<string> {
    try {
      const fromAccount = AccountId.fromString(fromAccountId);
      const toAccount = AccountId.fromString(toAccountId);
      const transferAmount = new Hbar(parseFloat(amount));
      const senderPrivateKey = PrivateKey.fromString(privateKey);
      
      // Create transfer transaction
      const tx = new TransferTransaction()
        .addHbarTransfer(fromAccount, transferAmount.negated()) // Subtract from sender
        .addHbarTransfer(toAccount, transferAmount) // Add to receiver
        .freezeWith(this.client);

      // Sign the transaction with the sender's private key
      const signTx = await tx.sign(senderPrivateKey);
      
      // Execute the transaction
      const submitTx = await signTx.execute(this.client);
      const receipt = await submitTx.getReceipt(this.client);
      
      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(`Transfer failed with status: ${receipt.status.toString()}`);
      }
      
      const transactionId = submitTx.transactionId.toString();
      this.logger.log(`Successfully transferred ${amount} HBAR from ${fromAccountId} to ${toAccountId}. Transaction ID: ${transactionId}`);
      
      return transactionId;
    } catch (error) {
      this.logger.error('Failed to transfer HBAR:', error);
      throw error;
    }
  }

  async mintNft(tokenId: string, metadata: string, privateKey: string, recipientAccountId?: string, userPrivateKey?: string): Promise<{ serialNumber: string; transactionHash: string }> {
    try {
      const token = TokenId.fromString(tokenId);
      const signerPrivateKey = PrivateKey.fromString(privateKey);
      
      // Create NFT mint transaction (always mints to treasury first)
      const tx = new TokenMintTransaction()
        .setTokenId(token)
        .setMetadata([Buffer.from(metadata)]) // Convert metadata to buffer
        .setMaxTransactionFee(new Hbar(5)); // Increased fee for minting

      // Freeze the transaction
      const frozenTx = tx.freezeWith(this.client);

      // Sign the transaction with the token's supply key
      const signTx = await frozenTx.sign(signerPrivateKey);
      
      // Execute the transaction
      const submitTx = await signTx.execute(this.client);
      const receipt = await submitTx.getReceipt(this.client);
      
      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(`NFT minting failed with status: ${receipt.status.toString()}`);
      }
      
      if (!receipt.serials || receipt.serials.length === 0) {
        throw new Error('NFT minting failed - no serial numbers returned');
      }
      
      const serialNumber = receipt.serials[0].toString();
      const transactionId = submitTx.transactionId.toString();
      
      // If recipient is specified, associate and transfer the NFT to them
      if (recipientAccountId && userPrivateKey) {
        this.logger.log(`Associating token ${tokenId} with recipient: ${recipientAccountId}`);
        await this.associateTokenWithAccount(tokenId, recipientAccountId, userPrivateKey);
        
        this.logger.log(`Transferring NFT to recipient: ${recipientAccountId}`);
        await this.transferNft(tokenId, serialNumber, this.operatorAccountId.toString(), recipientAccountId, this.operatorPrivateKey.toString());
        this.logger.log(`Successfully minted and transferred NFT: Token ${tokenId}, Serial ${serialNumber} to ${recipientAccountId}. Transaction ID: ${transactionId}`);
      } else {
        this.logger.log(`Successfully minted NFT to treasury: Token ${tokenId}, Serial ${serialNumber}. Transaction ID: ${transactionId}`);
      }
      
      return {
        serialNumber,
        transactionHash: transactionId,
      };
    } catch (error) {
      this.logger.error('Failed to mint NFT:', error);
      throw error;
    }
  }

  async associateTokenWithAccount(tokenId: string, accountId: string, privateKey: string): Promise<string> {
    try {
      this.logger.log(`Associating token ${tokenId} with account ${accountId}`);
      
      const token = TokenId.fromString(tokenId);
      const account = AccountId.fromString(accountId);
      const signerPrivateKey = PrivateKey.fromString(privateKey);

      // Create token association transaction
      const tx = new TokenAssociateTransaction()
        .setAccountId(account)
        .setTokenIds([token])
        .setMaxTransactionFee(new Hbar(5));

      // Freeze the transaction
      const frozenTx = tx.freezeWith(this.client);

      // Sign the transaction
      const signTx = await frozenTx.sign(signerPrivateKey);
      
      // Execute the transaction
      const submitTx = await signTx.execute(this.client);
      const receipt = await submitTx.getReceipt(this.client);
      
      if (receipt.status.toString() !== 'SUCCESS') {
        // Check if token is already associated (this is not an error)
        if (receipt.status.toString() === 'TOKEN_ALREADY_ASSOCIATED_TO_ACCOUNT') {
          this.logger.log(`Token ${tokenId} is already associated with account ${accountId}. Continuing...`);
          return submitTx.transactionId.toString();
        }
        throw new Error(`Token association failed with status: ${receipt.status.toString()}`);
      }
      
      const transactionId = submitTx.transactionId.toString();
      
      this.logger.log(`Successfully associated token ${tokenId} with account ${accountId}. Transaction ID: ${transactionId}`);
      
      return transactionId;
    } catch (error) {
      // Handle ReceiptStatusError specifically for TOKEN_ALREADY_ASSOCIATED_TO_ACCOUNT
      if (error.name === 'ReceiptStatusError' && error.status && error.status._code === 194) {
        this.logger.log(`Token ${tokenId} is already associated with account ${accountId}. Continuing...`);
        return 'already-associated';
      }
      
      this.logger.error('Failed to associate token with account:', error);
      throw error;
    }
  }

  async transferNft(tokenId: string, serialNumber: string, fromAccountId: string, toAccountId: string, privateKey: string): Promise<string> {
    try {
      this.logger.log(`Transferring NFT: Token ${tokenId}, Serial ${serialNumber} from ${fromAccountId} to ${toAccountId}`);
      
      const token = TokenId.fromString(tokenId);
      const fromAccount = AccountId.fromString(fromAccountId);
      const toAccount = AccountId.fromString(toAccountId);
      const serial = parseInt(serialNumber, 10);
      const signerPrivateKey = PrivateKey.fromString(privateKey);

      // Create NFT transfer transaction
      const tx = new TransferTransaction()
        .addNftTransfer(token, serial, fromAccount, toAccount)
        .setMaxTransactionFee(new Hbar(5));

      // Freeze the transaction
      const frozenTx = tx.freezeWith(this.client);

      // Sign the transaction
      const signTx = await frozenTx.sign(signerPrivateKey);
      
      // Execute the transaction
      const submitTx = await signTx.execute(this.client);
      const receipt = await submitTx.getReceipt(this.client);
      
      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(`NFT transfer failed with status: ${receipt.status.toString()}`);
      }
      
      const transactionId = submitTx.transactionId.toString();
      
      this.logger.log(`Successfully transferred NFT: Token ${tokenId}, Serial ${serialNumber} from ${fromAccountId} to ${toAccountId}. Transaction ID: ${transactionId}`);
      
      return transactionId;
    } catch (error) {
      this.logger.error('Failed to transfer NFT:', error);
      throw error;
    }
  }

  async burnNft(tokenId: string, serialNumber: string, privateKey: string): Promise<string> {
    try {
      const token = TokenId.fromString(tokenId);
      const serial = parseInt(serialNumber, 10);
      const signerPrivateKey = PrivateKey.fromString(privateKey);
      
      // Create NFT burn transaction
      const tx = new TokenBurnTransaction()
        .setTokenId(token)
        .setSerials([serial]) // Array of serial numbers to burn
        .freezeWith(this.client);

      // Sign the transaction with the token's supply key
      const signTx = await tx.sign(signerPrivateKey);
      
      // Execute the transaction
      const submitTx = await signTx.execute(this.client);
      const receipt = await submitTx.getReceipt(this.client);
      
      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(`NFT burning failed with status: ${receipt.status.toString()}`);
      }
      
      const transactionId = submitTx.transactionId.toString();
      this.logger.log(`Successfully burned NFT: Token ${tokenId}, Serial ${serialNumber}. Transaction ID: ${transactionId}`);
      
      return transactionId;
    } catch (error) {
      this.logger.error('Failed to burn NFT:', error);
      throw error;
    }
  }

  /**
   * Fund a Hedera account with HBAR from the operator account
   * This is useful for initializing user accounts with initial balance
   */
  /**
   * Funds a Hedera account with HBAR from the operator account
   * @param targetAccountId The account ID to fund
   * @param amount The amount of HBAR to transfer (as string)
   * @param options Additional funding options
   * @returns Promise resolving to funding operation details
   */
  async fundAccount(
    targetAccountId: string,
    amount: string,
    options: FundingOptions = {}
  ): Promise<FundingResult> {
    const { memo, maxTransactionFee = 1 } = options;

    // Validate inputs
    const accountValidation = this.validateAccountId(targetAccountId);
    if (!accountValidation.isValid) {
      throw new BadRequestException(`Invalid target account ID: ${accountValidation.error}`);
    }

    const amountValidation = this.validateAmount(amount);
    if (!amountValidation.isValid) {
      throw new BadRequestException(`Invalid amount: ${amountValidation.error}`);
    }

    try {
      const toAccount = AccountId.fromString(targetAccountId);
      const fundingAmount = new Hbar(parseFloat(amount));
      const operatorAccountId = this.operatorAccountId;
      
      this.logger.log(
        `Funding account ${targetAccountId} with ${amount} HBAR from operator ${operatorAccountId.toString()}`
      );
      
      // Create transfer transaction
      const transaction = new TransferTransaction()
        .addHbarTransfer(operatorAccountId, fundingAmount.negated()) // Subtract from operator
        .addHbarTransfer(toAccount, fundingAmount) // Add to target account
        .setMaxTransactionFee(new Hbar(maxTransactionFee));

      // Add memo if provided
      if (memo) {
        transaction.setTransactionMemo(memo);
      }

      // Execute transaction
      const frozenTransaction = transaction.freezeWith(this.client);
      const response: TransactionResponse = await frozenTransaction.execute(this.client);
      const receipt: TransactionReceipt = await response.getReceipt(this.client);
      
      // Validate transaction success
      if (receipt.status !== Status.Success) {
        throw new Error(`Funding failed with status: ${receipt.status.toString()}`);
      }
      
      const transactionId = response.transactionId.toString();
      const timestamp = new Date();
      
      this.logger.log(
        `Successfully funded account ${targetAccountId} with ${amount} HBAR. Transaction ID: ${transactionId}`
      );
      
      return {
        transactionId,
        fromAccountId: operatorAccountId.toString(),
        toAccountId: targetAccountId,
        amount,
        memo,
        timestamp,
      };
    } catch (error) {
      this.logger.error('Failed to fund account:', error);
      
      if (error.message?.includes('INSUFFICIENT_PAYER_BALANCE')) {
        throw new BadRequestException('Operator account has insufficient balance for funding');
      }
      
      if (error.message?.includes('INVALID_ACCOUNT_ID')) {
        throw new BadRequestException(`Target account ${targetAccountId} does not exist`);
      }
      
      throw new InternalServerErrorException(`Funding operation failed: ${error.message}`);
    }
  }

  /**
   * Initialize a new user account with a specific HBAR balance
   * This creates the account AND funds it in one operation
   */
  async initializeAccountWithBalance(initialBalance: string): Promise<{ accountId: string; privateKey: string; publicKey: string; fundingTransactionId: string }> {
    try {
      const newPrivateKey = PrivateKey.generateED25519();
      const newPublicKey = newPrivateKey.publicKey;
      const balance = new Hbar(parseFloat(initialBalance));
      
      // ⚠️ SECURITY WARNING: This is a CUSTODIAL approach!
      // The backend generates and stores private keys, making it responsible for wallet security.
      // Consider implementing non-custodial flows where users manage their own keys.
      
      // Create account transaction on Hedera network with the specified initial balance
      const tx = new AccountCreateTransaction()
        .setKey(newPublicKey)
        .setInitialBalance(balance) // Set custom initial balance
        .freezeWith(this.client);

      // Execute the transaction
      const response = await tx.execute(this.client);
      const receipt = await response.getReceipt(this.client);
      
      if (!receipt.accountId) {
        throw new Error('Account creation failed - no account ID returned');
      }

      const newAccountId = receipt.accountId;
      const transactionId = response.transactionId.toString();
      
      this.logger.log(`Successfully created and initialized Hedera account: ${newAccountId.toString()} with ${initialBalance} HBAR`);
      
      return {
        accountId: newAccountId.toString(),
        privateKey: newPrivateKey.toString(),
        publicKey: newPublicKey.toString(),
        fundingTransactionId: transactionId,
      };
    } catch (error) {
      this.logger.error('Failed to initialize account with balance:', error);
      throw error;
    }
  }

  /**
   * Validates Hedera account ID format
   * @param accountId The account ID to validate
   * @returns Validation result
   */
  private validateAccountId(accountId: string): ValidationResult {
    if (!accountId || typeof accountId !== 'string') {
      return { isValid: false, error: 'Account ID is required and must be a string' };
    }

    // Hedera account ID format: 0.0.123456
    const accountIdRegex = /^0\.0\.[1-9]\d*$/;
    if (!accountIdRegex.test(accountId)) {
      return { isValid: false, error: 'Account ID must be in format 0.0.123456' };
    }

    try {
      AccountId.fromString(accountId);
      return { isValid: true };
    } catch (error) {
      return { isValid: false, error: `Invalid account ID format: ${error.message}` };
    }
  }

  /**
   * Validates HBAR amount format
   * @param amount The amount to validate
   * @returns Validation result
   */
  private validateAmount(amount: string): ValidationResult {
    if (!amount || typeof amount !== 'string') {
      return { isValid: false, error: 'Amount is required and must be a string' };
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount)) {
      return { isValid: false, error: 'Amount must be a valid number' };
    }

    if (numericAmount <= 0) {
      return { isValid: false, error: 'Amount must be greater than 0' };
    }

    if (numericAmount > 50000000000) { // 50 billion HBAR max
      return { isValid: false, error: 'Amount exceeds maximum allowed value' };
    }

    return { isValid: true };
  }

  /**
   * Gets HashScan URLs for account and transaction verification
   * @param accountId The account ID to generate URLs for
   * @param transactionId Optional transaction ID
   * @returns HashScan URLs
   */
  getHashScanUrls(accountId: string, transactionId?: string): HashScanUrls {
    const baseUrl = this.networkInfo.explorerUrl;
    
    const result: HashScanUrls = {
      accountUrl: `${baseUrl}/account/${accountId}`,
    };

    if (transactionId) {
      result.transactionUrl = `${baseUrl}/transaction/${transactionId}`;
    }

    return result;
  }

  /**
   * Gets the current network information
   * @returns Network information
   */
  public getNetworkInfo(): NetworkInfo {
    return this.networkInfo;
  }

  /**
   * Gets the operator account information
   * @returns Operator account details
   */
  getOperatorInfo(): { accountId: string; network: string } {
    return {
      accountId: this.operatorAccountId.toString(),
      network: this.networkInfo.name,
    };
  }

  /**
   * Validates that the operator account has sufficient balance for operations
   * @param requiredAmount Required amount in HBAR
   * @returns Promise resolving to validation result
   */
  async validateOperatorBalance(requiredAmount: number): Promise<ValidationResult> {
    try {
      const balance = await this.getAccountBalance(this.operatorAccountId.toString());
      const currentBalance = parseFloat(balance.hbar);
      
      if (currentBalance < requiredAmount) {
        return {
          isValid: false,
          error: `Operator account has insufficient balance. Required: ${requiredAmount} HBAR, Available: ${currentBalance} HBAR`,
        };
      }
      
      return { isValid: true };
    } catch (error) {
      return {
        isValid: false,
        error: `Failed to check operator balance: ${error.message}`,
      };
    }
  }
}
