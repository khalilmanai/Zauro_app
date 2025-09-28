import { AccountId, PrivateKey, PublicKey, Hbar } from '@hashgraph/sdk';

/**
 * Response interface for account creation operations
 */
export interface AccountCreationResult {
  /** The newly created Hedera account ID (e.g., "0.0.123456") */
  accountId: string;
  /** The private key in string format (DER-encoded hex) */
  privateKey: string;
  /** The public key in string format (DER-encoded hex) */
  publicKey: string;
  /** The transaction ID of the account creation */
  transactionId: string;
  /** Initial balance set for the account */
  initialBalance: string;
}

/**
 * Response interface for account balance queries
 */
export interface AccountBalance {
  /** HBAR balance in string format */
  hbar: string;
  /** ZAU token balance in string format */
  zau: string;
  /** Additional token balances (tokenId -> balance) */
  tokens?: Record<string, string>;
  /** Timestamp of the balance query */
  timestamp: Date;
}

/**
 * Response interface for funding operations
 */
export interface FundingResult {
  /** The transaction ID of the funding operation */
  transactionId: string;
  /** Source account ID (operator account) */
  fromAccountId: string;
  /** Target account ID */
  toAccountId: string;
  /** Amount transferred in HBAR */
  amount: string;
  /** Optional transaction memo */
  memo?: string;
  /** Transaction timestamp */
  timestamp: Date;
}

/**
 * Configuration interface for Hedera client initialization
 */
export interface HederaConfig {
  /** Operator account ID */
  accountId: string;
  /** Operator private key */
  privateKey: string;
  /** Network (testnet, previewnet, mainnet) */
  network: 'testnet' | 'previewnet' | 'mainnet';
  /** Mirror node URL for queries */
  mirrorNodeUrl?: string;
}

/**
 * Options for account creation
 */
export interface CreateAccountOptions {
  /** Initial HBAR balance (default: 10) */
  initialBalance?: number;
  /** Account memo */
  memo?: string;
  /** Maximum transaction fee in HBAR */
  maxTransactionFee?: number;
}

/**
 * Options for funding operations
 */
export interface FundingOptions {
  /** Transaction memo */
  memo?: string;
  /** Maximum transaction fee in HBAR */
  maxTransactionFee?: number;
}

/**
 * Validation result interface
 */
export interface ValidationResult {
  /** Whether the input is valid */
  isValid: boolean;
  /** Error message if validation failed */
  error?: string;
}

/**
 * Network information interface
 */
export interface NetworkInfo {
  /** Network name */
  name: string;
  /** HashScan explorer base URL */
  explorerUrl: string;
  /** Mirror node URL */
  mirrorNodeUrl: string;
}

/**
 * HashScan verification URLs
 */
export interface HashScanUrls {
  /** Account page URL */
  accountUrl: string;
  /** Transaction page URL */
  transactionUrl?: string;
}
