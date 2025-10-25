import { Injectable, Logger, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { DidService } from './did.service';
import { EncryptionService } from '../wallet/services/encryption.service';

// Verifiable Credential Interfaces
export interface VerifiableCredential {
  '@context': string[];
  type: string[];
  issuer: string;
  issuanceDate: string;
  expirationDate?: string;
  credentialSubject: CredentialSubject;
  credentialStatus?: CredentialStatus;
  proof?: Proof;
}

export interface CredentialSubject {
  id: string;
  type: string;
  [key: string]: any;
}

export interface CredentialStatus {
  id: string;
  type: string;
}

export interface Proof {
  type: string;
  created: string;
  verificationMethod: string;
  proofPurpose: string;
  jws: string;
}

export interface KycCredentialData {
  level: 'basic' | 'enhanced' | 'premium';
  verifiedAt: Date;
  provider: string;
  country?: string;
  documentType?: string;
}

export interface ReputationCredentialData {
  score: number;
  totalTrades: number;
  successfulTrades: number;
  averageRating: number;
  lastUpdated: Date;
}

export interface VeterinaryCredentialData {
  vetId: string;
  vetName: string;
  examinationDate: Date;
  healthStatus: 'healthy' | 'sick' | 'recovering';
  vaccinations: string[];
  notes: string;
  animalId: string;
}

@Injectable()
export class CredentialsService {
  private readonly logger = new Logger(CredentialsService.name);
  private readonly platformDid: string;

  constructor(
    private prisma: PrismaService,
    private didService: DidService,
    private encryptionService: EncryptionService,
  ) {
    // Platform DID - in production, this would be your organization's DID
    this.platformDid = 'did:hedera:testnet:0.0.123456'; // Replace with your platform DID
  }

  /**
   * Issue a KYC credential to a user
   */
  async issueKycCredential(
    userId: string,
    kycData: KycCredentialData
  ): Promise<VerifiableCredential> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { did: true },
      });

      if (!user?.did) {
        throw new BadRequestException('User does not have a DID');
      }

      const credentialId = `kyc-${userId}-${Date.now()}`;
      
      const credential: VerifiableCredential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential', 'KycCredential'],
        issuer: this.platformDid,
        issuanceDate: new Date().toISOString(),
        credentialSubject: {
          id: user.did,
          type: 'KycCredential',
          kycLevel: kycData.level,
          verifiedAt: kycData.verifiedAt.toISOString(),
          provider: kycData.provider,
          country: kycData.country,
          documentType: kycData.documentType,
          status: 'verified',
        },
        credentialStatus: {
          id: `https://api.zauro.com/credentials/status/${credentialId}`,
          type: 'CredentialStatusList2021',
        },
      };

      // Sign the credential
      const signedCredential = await this.signCredential(credential);
      
      // Store in database
      await this.storeCredential(userId, 'KYC', signedCredential, credentialId);
      
      this.logger.log(`Issued KYC credential for user ${userId}`);
      return signedCredential;
    } catch (error) {
      this.logger.error(`Failed to issue KYC credential for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Issue a reputation credential
   */
  async issueReputationCredential(
    userId: string,
    reputationData: ReputationCredentialData
  ): Promise<VerifiableCredential> {
    try {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
        select: { did: true },
      });

      if (!user?.did) {
        throw new BadRequestException('User does not have a DID');
      }

      const credentialId = `reputation-${userId}-${Date.now()}`;
      
      const credential: VerifiableCredential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential', 'ReputationCredential'],
        issuer: this.platformDid,
        issuanceDate: new Date().toISOString(),
        credentialSubject: {
          id: user.did,
          type: 'ReputationCredential',
          reputationScore: reputationData.score,
          totalTrades: reputationData.totalTrades,
          successfulTrades: reputationData.successfulTrades,
          averageRating: reputationData.averageRating,
          lastUpdated: reputationData.lastUpdated.toISOString(),
          platform: 'Zauro Marketplace',
        },
      };

      const signedCredential = await this.signCredential(credential);
      await this.storeCredential(userId, 'REPUTATION', signedCredential, credentialId);
      
      this.logger.log(`Issued reputation credential for user ${userId}`);
      return signedCredential;
    } catch (error) {
      this.logger.error(`Failed to issue reputation credential for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Issue a veterinary credential for animals
   */
  async issueVeterinaryCredential(
    animalId: string,
    vetData: VeterinaryCredentialData
  ): Promise<VerifiableCredential> {
    try {
      const credentialId = `vet-${animalId}-${Date.now()}`;
      
      const credential: VerifiableCredential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential', 'VeterinaryCredential'],
        issuer: this.platformDid, // In production, this would be the vet's DID
        issuanceDate: new Date().toISOString(),
        credentialSubject: {
          id: `did:hedera:testnet:${animalId}`, // Animal DID (simplified)
          type: 'VeterinaryCredential',
          animalId: animalId,
          examinationDate: vetData.examinationDate.toISOString(),
          healthStatus: vetData.healthStatus,
          vaccinations: vetData.vaccinations,
          notes: vetData.notes,
          veterinarian: {
            id: vetData.vetId,
            name: vetData.vetName,
          },
        },
      };

      const signedCredential = await this.signCredential(credential);
      
      // Find the animal's owner to store the credential
      const animal = await this.prisma.animal.findUnique({
        where: { id: animalId },
        select: { ownerId: true },
      });

      if (animal) {
        await this.storeCredential(animal.ownerId, 'VETERINARY', signedCredential, credentialId);
      }
      
      this.logger.log(`Issued veterinary credential for animal ${animalId}`);
      return signedCredential;
    } catch (error) {
      this.logger.error(`Failed to issue veterinary credential for animal ${animalId}:`, error);
      throw error;
    }
  }

  /**
   * Store credential in database
   */
  private async storeCredential(
    userId: string,
    type: 'KYC' | 'REPUTATION' | 'VETERINARY' | 'IDENTITY' | 'BUSINESS_LICENSE',
    credential: VerifiableCredential,
    credentialId: string
  ): Promise<void> {
    try {
      await this.prisma.credential.create({
        data: {
          userId,
          type: type as any,
          issuerDid: credential.issuer,
          subjectDid: credential.credentialSubject.id,
          credentialId,
          credentialData: credential as any,
          expiresAt: credential.expirationDate ? new Date(credential.expirationDate) : null,
        },
      });
    } catch (error) {
      this.logger.error(`Failed to store credential ${credentialId}:`, error);
      throw error;
    }
  }

  /**
   * Sign a credential (simplified implementation)
   */
  private async signCredential(credential: VerifiableCredential): Promise<VerifiableCredential> {
    // In a production implementation, this would:
    // 1. Create a cryptographic signature using the platform's private key
    // 2. Add the signature as a proof to the credential
    // 3. Use proper JSON-LD signing methods
    
    const proof: Proof = {
      type: 'Ed25519Signature2020',
      created: new Date().toISOString(),
      verificationMethod: `${this.platformDid}#key-1`,
      proofPurpose: 'assertionMethod',
      jws: 'mock-signature', // Replace with actual signature
    };

    return {
      ...credential,
      proof,
    };
  }

  /**
   * Verify a credential
   */
  async verifyCredential(credential: VerifiableCredential): Promise<{
    valid: boolean;
    errors: string[];
  }> {
    const errors: string[] = [];
    
    try {
      // Check credential structure
      if (!credential['@context'] || !credential.type || !credential.issuer) {
        errors.push('Invalid credential structure');
      }

      // Check expiration
      if (credential.expirationDate && new Date(credential.expirationDate) < new Date()) {
        errors.push('Credential has expired');
      }

      // Verify signature (simplified - in production, use proper verification)
      if (!credential.proof) {
        errors.push('Credential missing proof');
      }

      // Check credential status
      if (credential.credentialStatus) {
        const statusValid = await this.checkCredentialStatus(credential.credentialStatus.id);
        if (!statusValid) {
          errors.push('Credential has been revoked');
        }
      }

      return {
        valid: errors.length === 0,
        errors,
      };
    } catch (error) {
      errors.push(`Verification error: ${error.message}`);
      return { valid: false, errors };
    }
  }

  /**
   * Check credential status (simplified implementation)
   */
  private async checkCredentialStatus(statusUrl: string): Promise<boolean> {
    // In production, this would check the credential status list
    // For now, we'll check if the credential exists in our database
    try {
      const credentialId = statusUrl.split('/').pop();
      const credential = await this.prisma.credential.findUnique({
        where: { credentialId },
        select: { status: true },
      });
      
      return credential?.status === 'ACTIVE';
    } catch (error) {
      return false;
    }
  }

  /**
   * Get user's credentials
   */
  async getUserCredentials(userId: string, type?: string): Promise<any[]> {
    try {
      const where: any = { userId };
      if (type) {
        where.type = type;
      }

      const credentials = await this.prisma.credential.findMany({
        where,
        orderBy: { issuedAt: 'desc' },
      });

      return credentials.map(cred => ({
        id: cred.id,
        type: cred.type,
        status: cred.status,
        credentialData: cred.credentialData,
        issuedAt: cred.issuedAt,
        expiresAt: cred.expiresAt,
      }));
    } catch (error) {
      this.logger.error(`Failed to get credentials for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Revoke a credential
   */
  async revokeCredential(credentialId: string): Promise<void> {
    try {
      await this.prisma.credential.update({
        where: { credentialId },
        data: {
          status: 'REVOKED',
          revokedAt: new Date(),
        },
      });

      this.logger.log(`Revoked credential ${credentialId}`);
    } catch (error) {
      this.logger.error(`Failed to revoke credential ${credentialId}:`, error);
      throw error;
    }
  }
}
