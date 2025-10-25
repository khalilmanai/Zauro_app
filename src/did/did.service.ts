import { Injectable, Logger, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { EncryptionService } from '../wallet/services/encryption.service';
import {
  Client,
  PrivateKey,
  PublicKey,
  AccountId,
  AccountCreateTransaction,
  Hbar,
  Status,
  TransactionResponse,
  TransactionReceipt,
} from '@hashgraph/sdk';

// DID Interfaces
export interface DidDocument {
  '@context': string[];
  id: string;
  verificationMethod: VerificationMethod[];
  service: ServiceEndpoint[];
  created: string;
  updated: string;
}

export interface VerificationMethod {
  id: string;
  type: string;
  controller: string;
  publicKeyMultibase: string;
}

export interface ServiceEndpoint {
  id: string;
  type: string;
  serviceEndpoint: string;
}

export interface DidCreationResult {
  did: string;
  document: DidDocument;
  privateKey: string;
  publicKey: string;
}

@Injectable()
export class DidService {
  private readonly logger = new Logger(DidService.name);
  private client: Client;
  private readonly operatorAccountId: AccountId;
  private readonly operatorPrivateKey: PrivateKey;

  constructor(
    private configService: ConfigService,
    private prisma: PrismaService,
    private encryptionService: EncryptionService,
  ) {
    this.initializeHederaClient();
  }

  private initializeHederaClient() {
    const network = this.configService.get<string>('hedera.network') || 'testnet';
    const operatorId = this.configService.get<string>('hedera.accountId');
    const operatorKey = this.configService.get<string>('hedera.privateKey');

    if (!operatorId || !operatorKey) {
      throw new Error('Hedera operator credentials not configured');
    }

    // Initialize Hedera client
    this.client = Client.forName(network);
    this.client.setOperator(AccountId.fromString(operatorId), PrivateKey.fromString(operatorKey));

    this.logger.log(`Initialized Hedera DID service for ${network} network`);
  }

  /**
   * Generate a new key pair for DID
   */
  private generateKeyPair(): { privateKey: PrivateKey; publicKey: string } {
    try {
      const privateKey = PrivateKey.generateED25519();
      const publicKey = privateKey.publicKey.toString();
      
      return { privateKey, publicKey };
    } catch (error) {
      this.logger.error('Failed to generate key pair:', error);
      throw new InternalServerErrorException('Failed to generate cryptographic keys');
    }
  }

  /**
   * Create a new Hedera account for DID
   */
  private async createHederaAccount(
    publicKey: string,
    memo?: string
  ): Promise<{ accountId: string; transactionId: string }> {
    try {
      const parsedPublicKey = PublicKey.fromString(publicKey);
      const initialBalance = new Hbar(1); // Minimal balance for DID account
      
      this.logger.log(`Creating Hedera account for DID with ${initialBalance} HBAR initial balance`);
      
      // Create account transaction
      const transaction = new AccountCreateTransaction()
        .setKey(parsedPublicKey)
        .setInitialBalance(initialBalance)
        .setMaxTransactionFee(new Hbar(2));

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

      const accountId = receipt.accountId.toString();
      const transactionId = response.transactionId.toString();
      
      this.logger.log(`Successfully created Hedera account: ${accountId} with transaction ID: ${transactionId}`);
      
      return { accountId, transactionId };
    } catch (error) {
      this.logger.error('Failed to create Hedera account:', error);
      throw new InternalServerErrorException(`Account creation failed: ${error.message}`);
    }
  }

  /**
   * Create a new DID for a user
   */
  async createUserDid(userId: string): Promise<DidCreationResult> {
    try {
      this.logger.log(`Creating DID for user ${userId}`);

      // Generate new key pair for the DID
      const { privateKey, publicKey } = this.generateKeyPair();
      
      // Create Hedera account for the DID
      const { accountId } = await this.createHederaAccount(
        publicKey,
        `DID account for user ${userId}`
      );

      // Create DID identifier
      const did = `did:hedera:${this.configService.get<string>('hedera.network')}:${accountId}`;
      
      // Create DID document
      const didDocument: DidDocument = {
        '@context': ['https://www.w3.org/ns/did/v1'],
        id: did,
        verificationMethod: [
          {
            id: `${did}#key-1`,
            type: 'Ed25519VerificationKey2020',
            controller: did,
            publicKeyMultibase: publicKey,
          }
        ],
        service: [
          {
            id: `${did}#wallet-service`,
            type: 'WalletService',
            serviceEndpoint: `https://api.zauro.com/wallets/${userId}`,
          },
          {
            id: `${did}#profile-service`,
            type: 'ProfileService', 
            serviceEndpoint: `https://api.zauro.com/users/${userId}/profile`,
          }
        ],
        created: new Date().toISOString(),
        updated: new Date().toISOString(),
      };

      this.logger.log(`Created DID for user ${userId}: ${did}`);
      
      return {
        did,
        document: didDocument,
        privateKey: privateKey.toString(),
        publicKey,
      };
    } catch (error) {
      this.logger.error(`Failed to create DID for user ${userId}:`, error);
      throw new InternalServerErrorException(`DID creation failed: ${error.message}`);
    }
  }

  /**
   * Resolve a DID to get its document
   */
  async resolveDid(did: string): Promise<DidDocument> {
    try {
      // First try to resolve from our database cache
      const cachedDocument = await this.getCachedDidDocument(did);
      if (cachedDocument) {
        return cachedDocument;
      }

      // Extract account ID from DID
      const accountId = this.extractAccountIdFromDid(did);
      
      // For Hedera DIDs, we'll create a basic document structure
      // In a full implementation, this would query the Hedera network
      const didDocument: DidDocument = {
        '@context': ['https://www.w3.org/ns/did/v1'],
        id: did,
        verificationMethod: [
          {
            id: `${did}#key-1`,
            type: 'Ed25519VerificationKey2020',
            controller: did,
            publicKeyMultibase: 'placeholder-key', // Would be fetched from Hedera
          }
        ],
        service: [
          {
            id: `${did}#wallet-service`,
            type: 'WalletService',
            serviceEndpoint: `https://api.zauro.com/wallets/${accountId}`,
          }
        ],
        created: new Date().toISOString(),
        updated: new Date().toISOString(),
      };

      this.logger.log(`Resolved DID: ${did}`);
      return didDocument;
    } catch (error) {
      this.logger.error(`Failed to resolve DID ${did}:`, error);
      throw new BadRequestException(`Failed to resolve DID: ${error.message}`);
    }
  }

  /**
   * Update DID document (add new services, keys, etc.)
   */
  async updateDidDocument(
    did: string, 
    privateKey: string, 
    updates: Partial<DidDocument>
  ): Promise<DidDocument> {
    try {
      // Get current document
      const currentDocument = await this.resolveDid(did);
      
      // Merge updates
      const updatedDocument: DidDocument = {
        ...currentDocument,
        ...updates,
        updated: new Date().toISOString(),
      };

      this.logger.log(`Updated DID document: ${did}`);
      return updatedDocument;
    } catch (error) {
      this.logger.error(`Failed to update DID ${did}:`, error);
      throw new InternalServerErrorException(`DID update failed: ${error.message}`);
    }
  }

  /**
   * Get cached DID document from database
   */
  private async getCachedDidDocument(did: string): Promise<DidDocument | null> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { did },
        select: { didDocument: true },
      });

      return (user?.didDocument as unknown as DidDocument) || null;
    } catch (error) {
      return null;
    }
  }

  /**
   * Extract account ID from Hedera DID
   */
  private extractAccountIdFromDid(did: string): string {
    const match = did.match(/did:hedera:[^:]+:(.+)/);
    if (!match) {
      throw new BadRequestException('Invalid Hedera DID format');
    }
    return match[1];
  }

  /**
   * Validate DID format
   */
  validateDid(did: string): { isValid: boolean; error?: string } {
    try {
      if (!did.startsWith('did:hedera:')) {
        return { isValid: false, error: 'DID must start with did:hedera:' };
      }

      const parts = did.split(':');
      if (parts.length !== 4) {
        return { isValid: false, error: 'Invalid DID format' };
      }

      const accountId = parts[3];
      if (!accountId.match(/^0\.0\.\d+$/)) {
        return { isValid: false, error: 'Invalid Hedera account ID format' };
      }

      return { isValid: true };
    } catch (error) {
      return { isValid: false, error: error.message };
    }
  }

  /**
   * Get user's DID from database
   */
  async getUserDid(userId: string): Promise<{ did: string; document: DidDocument } | null> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { did: true, didDocument: true },
      });

      if (!user?.did) {
        return null;
      }

      const document = (user.didDocument as unknown as DidDocument) || await this.resolveDid(user.did);
      
      return {
        did: user.did,
        document,
      };
    } catch (error) {
      this.logger.error(`Failed to get DID for user ${userId}:`, error);
      return null;
    }
  }
}
