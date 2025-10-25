import { Injectable, ForbiddenException, NotFoundException, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { HederaService } from '../wallet/services/hedera.service';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class CollectionsService implements OnModuleInit {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hedera: HederaService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Initialize default collection on module startup
   * Creates a default collection if none exists
   */
  async onModuleInit() {
    try {
      await this.ensureDefaultCollection();
    } catch (error) {
      console.error('Failed to initialize default collection on startup:', error);
      // Don't throw error to prevent app startup failure
    }
  }

  /**
   * Ensure a default collection exists, create one if it doesn't
   */
  private async ensureDefaultCollection(): Promise<void> {
    try {
      // Check if any default collection exists
      const existingDefault = await this.prisma.collection.findFirst({
        where: { isDefault: true, status: 'ACTIVE' }
      });

      if (existingDefault) {
        console.log(`✅ Default collection already exists: ${existingDefault.name} (${existingDefault.tokenId})`);
        return;
      }

      // Check if any collection exists at all
      const anyCollection = await this.prisma.collection.findFirst({
        where: { status: 'ACTIVE' }
      });

      if (anyCollection) {
        // Set the first active collection as default
        await this.prisma.collection.update({
          where: { id: anyCollection.id },
          data: { isDefault: true }
        });
        console.log(`✅ Set existing collection as default: ${anyCollection.name} (${anyCollection.tokenId})`);
        return;
      }

      // No collections exist, create a default one
      console.log('🔄 No collections found, creating default collection...');
      const defaultCollection = await this.createCollection({
        name: 'Zauro Animals',
        symbol: 'ZANML',
        memo: 'Default animal NFT collection for Zauro marketplace',
        maxSupply: 10000,
        setDefault: true,
      });

      console.log(`✅ Created default collection: ${defaultCollection.name} (${defaultCollection.tokenId})`);
    } catch (error) {
      console.error('Error ensuring default collection:', error);
      throw error;
    }
  }

  /**
   * Get or create a system user for collection management
   * This user represents the system/operator account
   */
  private async getSystemUser(): Promise<string> {
    const systemEmail = 'system@zauro.com';
    
    let systemUser = await this.prisma.user.findUnique({
      where: { email: systemEmail }
    });

    if (!systemUser) {
      systemUser = await this.prisma.user.create({
        data: {
          email: systemEmail,
          firstName: 'System',
          lastName: 'Account',
          password: 'system-account-not-for-login',
          role: 'ADMIN',
          isVerified: true,
          isActive: true,
        }
      });
    }

    return systemUser.id;
  }

  async createCollection(params: {
    name: string;
    symbol: string;
    memo?: string;
    maxSupply?: number;
    setDefault?: boolean;
  }) {
    const { name, symbol, memo, maxSupply, setDefault } = params;

    // Get system user for collection management
    const systemUserId = await this.getSystemUser();

    const { tokenId } = await this.hedera.createNftCollection({ name, symbol, memo, maxSupply });

    const created = await this.prisma.collection.create({
      data: {
        name,
        symbol,
        tokenId,
        treasuryAccountId: this.hedera.getOperatorInfo().accountId,
        createdByUserId: systemUserId,
        isDefault: Boolean(setDefault),
      },
    });

    if (setDefault) {
      await this.prisma.collection.updateMany({ data: { isDefault: false }, where: { id: { not: created.id } } });
      await this.prisma.collection.update({ where: { id: created.id }, data: { isDefault: true } });
    }

    return created;
  }

  async listCollections() {
    return this.prisma.collection.findMany({ orderBy: { createdAt: 'desc' } });
  }

  async getDefaultCollection() {
    const col = await this.prisma.collection.findFirst({ where: { isDefault: true, status: 'ACTIVE' } });
    if (!col) {
      throw new NotFoundException('Default collection not set');
    }
    return col;
  }

  /** Get the default collection for minting; if full and autoRotate, create a new one and set as default */
  async getOrRotateDefaultForMint(params: { namePrefix?: string; symbolPrefix?: string; memo?: string; }): Promise<{ tokenId: string; id: string; name: string; symbol: string; }> {
    const col = await this.getDefaultCollection();

    // If collection has maxSupply set, check on-chain supply
    if (col.maxSupply && col.autoRotate) {
      const info = await this.hedera.getTokenInfo(col.tokenId);
      if (info.maxSupply && info.totalSupply >= info.maxSupply) {
        const suffix = new Date().getTime().toString().slice(-6);
        const name = `${params.namePrefix || col.name}-${suffix}`;
        const symbol = `${params.symbolPrefix || col.symbol}${suffix.slice(-3)}`;
        const created = await this.createCollection({
          name,
          symbol,
          memo: params.memo,
          maxSupply: col.maxSupply,
          setDefault: true,
        });
        return { tokenId: created.tokenId, id: created.id, name: created.name, symbol: created.symbol };
      }
    }

    return { tokenId: col.tokenId, id: col.id, name: col.name, symbol: col.symbol };
  }

  async disableCollection(id: string) {
    return this.prisma.collection.update({ where: { id }, data: { status: 'DISABLED', isDefault: false } });
  }

  async setDefault(id: string) {
    const exists = await this.prisma.collection.findUnique({ where: { id } });
    if (!exists || exists.status !== 'ACTIVE') throw new NotFoundException('Collection not found or inactive');
    await this.prisma.collection.updateMany({ data: { isDefault: false } });
    return this.prisma.collection.update({ where: { id }, data: { isDefault: true } });
  }
}


