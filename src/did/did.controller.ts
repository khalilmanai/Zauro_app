import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Param, 
  UseGuards, 
  Request,
  NotFoundException,
  BadRequestException 
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiBody } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DidService } from './did.service';
import { CredentialsService, KycCredentialData, ReputationCredentialData, VeterinaryCredentialData } from './credentials.service';
import { PrismaService } from '../prisma/prisma.service';

// DTOs
export class CreateKycCredentialDto {
  level: 'basic' | 'enhanced' | 'premium';
  provider: string;
  country?: string;
  documentType?: string;
}

export class CreateReputationCredentialDto {
  score: number;
  totalTrades: number;
  successfulTrades: number;
  averageRating: number;
}

export class CreateVeterinaryCredentialDto {
  vetId: string;
  vetName: string;
  examinationDate: string;
  healthStatus: 'healthy' | 'sick' | 'recovering';
  vaccinations: string[];
  notes: string;
  animalId: string;
}

export class VerifyCredentialDto {
  credential: any;
}

@ApiTags('DID')
@Controller('did')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class DidController {
  constructor(
    private readonly didService: DidService,
    private readonly credentialsService: CredentialsService,
    private readonly prisma: PrismaService,
  ) {}

  @Get('my-did')
  @ApiOperation({ summary: 'Get current user\'s DID' })
  @ApiResponse({ status: 200, description: 'DID information retrieved successfully' })
  @ApiResponse({ status: 404, description: 'User does not have a DID' })
  async getMyDid(@Request() req: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: req.user.id },
      select: { did: true, didDocument: true },
    });

    if (!user?.did) {
      throw new NotFoundException('User does not have a DID');
    }

    const didInfo = await this.didService.getUserDid(req.user.id);
    if (!didInfo) {
      throw new NotFoundException('DID not found');
    }

    return {
      did: didInfo.did,
      document: didInfo.document,
      message: 'DID retrieved successfully',
    };
  }

  @Post('create')
  @ApiOperation({ summary: 'Create a new DID for the current user' })
  @ApiResponse({ status: 201, description: 'DID created successfully' })
  @ApiResponse({ status: 400, description: 'User already has a DID' })
  async createDid(@Request() req: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: req.user.id },
      select: { did: true },
    });

    if (user?.did) {
      throw new BadRequestException('User already has a DID');
    }

    try {
      const didResult = await this.didService.createUserDid(req.user.id);
      
      // Encrypt and store DID private key
      const encryptedPrivateKey = this.didService['encryptionService'].encrypt(didResult.privateKey);
      
      await this.prisma.user.update({
        where: { id: req.user.id },
        data: {
          did: didResult.did,
          didPrivateKey: encryptedPrivateKey,
          didDocument: didResult.document as any,
        },
      });

      return {
        did: didResult.did,
        document: didResult.document,
        message: 'DID created successfully',
      };
    } catch (error) {
      throw new BadRequestException(`Failed to create DID: ${error.message}`);
    }
  }

  @Get('resolve/:did')
  @ApiOperation({ summary: 'Resolve a DID to get its document' })
  @ApiResponse({ status: 200, description: 'DID resolved successfully' })
  @ApiResponse({ status: 400, description: 'Invalid DID format' })
  async resolveDid(@Param('did') did: string) {
    const validation = this.didService.validateDid(did);
    if (!validation.isValid) {
      throw new BadRequestException(validation.error);
    }

    try {
      const document = await this.didService.resolveDid(did);
      return {
        did,
        document,
        message: 'DID resolved successfully',
      };
    } catch (error) {
      throw new BadRequestException(`Failed to resolve DID: ${error.message}`);
    }
  }

  @Get('credentials')
  @ApiOperation({ summary: 'Get current user\'s credentials' })
  @ApiResponse({ status: 200, description: 'Credentials retrieved successfully' })
  async getMyCredentials(@Request() req: any) {
    const credentials = await this.credentialsService.getUserCredentials(req.user.id);
    return {
      credentials,
      count: credentials.length,
      message: 'Credentials retrieved successfully',
    };
  }

  @Get('credentials/:type')
  @ApiOperation({ summary: 'Get current user\'s credentials by type' })
  @ApiResponse({ status: 200, description: 'Credentials retrieved successfully' })
  async getCredentialsByType(@Param('type') type: string, @Request() req: any) {
    const credentials = await this.credentialsService.getUserCredentials(req.user.id, type.toUpperCase());
    return {
      credentials,
      type: type.toUpperCase(),
      count: credentials.length,
      message: 'Credentials retrieved successfully',
    };
  }

  @Post('credentials/issue/kyc')
  @ApiOperation({ summary: 'Issue KYC credential to current user' })
  @ApiBody({ type: CreateKycCredentialDto })
  @ApiResponse({ status: 201, description: 'KYC credential issued successfully' })
  @ApiResponse({ status: 400, description: 'User does not have a DID' })
  async issueKycCredential(
    @Body() kycData: CreateKycCredentialDto,
    @Request() req: any,
  ) {
    const credential = await this.credentialsService.issueKycCredential(
      req.user.id,
      {
        level: kycData.level,
        verifiedAt: new Date(),
        provider: kycData.provider,
        country: kycData.country,
        documentType: kycData.documentType,
      }
    );

    return {
      credential,
      message: 'KYC credential issued successfully',
    };
  }

  @Post('credentials/issue/reputation')
  @ApiOperation({ summary: 'Issue reputation credential to current user' })
  @ApiBody({ type: CreateReputationCredentialDto })
  @ApiResponse({ status: 201, description: 'Reputation credential issued successfully' })
  async issueReputationCredential(
    @Body() reputationData: CreateReputationCredentialDto,
    @Request() req: any,
  ) {
    const credential = await this.credentialsService.issueReputationCredential(
      req.user.id,
      {
        score: reputationData.score,
        totalTrades: reputationData.totalTrades,
        successfulTrades: reputationData.successfulTrades,
        averageRating: reputationData.averageRating,
        lastUpdated: new Date(),
      }
    );

    return {
      credential,
      message: 'Reputation credential issued successfully',
    };
  }

  @Post('credentials/issue/veterinary')
  @ApiOperation({ summary: 'Issue veterinary credential for an animal' })
  @ApiBody({ type: CreateVeterinaryCredentialDto })
  @ApiResponse({ status: 201, description: 'Veterinary credential issued successfully' })
  async issueVeterinaryCredential(
    @Body() vetData: CreateVeterinaryCredentialDto,
    @Request() req: any,
  ) {
    const credential = await this.credentialsService.issueVeterinaryCredential(
      vetData.animalId,
      {
        vetId: vetData.vetId,
        vetName: vetData.vetName,
        examinationDate: new Date(vetData.examinationDate),
        healthStatus: vetData.healthStatus,
        vaccinations: vetData.vaccinations,
        notes: vetData.notes,
        animalId: vetData.animalId,
      }
    );

    return {
      credential,
      message: 'Veterinary credential issued successfully',
    };
  }

  @Post('credentials/verify')
  @ApiOperation({ summary: 'Verify a credential' })
  @ApiBody({ type: VerifyCredentialDto })
  @ApiResponse({ status: 200, description: 'Credential verification completed' })
  async verifyCredential(@Body() verifyData: VerifyCredentialDto) {
    const result = await this.credentialsService.verifyCredential(verifyData.credential);
    return {
      ...result,
      message: result.valid ? 'Credential is valid' : 'Credential verification failed',
    };
  }

  @Post('credentials/revoke/:credentialId')
  @ApiOperation({ summary: 'Revoke a credential' })
  @ApiResponse({ status: 200, description: 'Credential revoked successfully' })
  @ApiResponse({ status: 404, description: 'Credential not found' })
  async revokeCredential(@Param('credentialId') credentialId: string) {
    try {
      await this.credentialsService.revokeCredential(credentialId);
      return {
        message: 'Credential revoked successfully',
        credentialId,
      };
    } catch (error) {
      throw new NotFoundException('Credential not found');
    }
  }
}
