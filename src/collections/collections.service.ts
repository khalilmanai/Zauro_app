import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { HederaService } from '../wallet/services/hedera.service';

@Injectable()
export class CollectionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly hedera: HederaService,
  ) {}

  async createCollection(params: {
    name: string;
    symbol: string;
    createdByUserId: string;
    memo?: string;
    maxSupply?: number;
    setDefault?: boolean;
  }) {
    const { name, symbol, createdByUserId, memo, maxSupply, setDefault } = params;

    const { tokenId } = await this.hedera.createNftCollection({ name, symbol, memo, maxSupply });

    const created = await this.prisma.collection.create({
      data: {
        name,
        symbol,
        tokenId,
        treasuryAccountId: this.hedera.getOperatorInfo().accountId,
        createdByUserId,
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
  async getOrRotateDefaultForMint(params: { namePrefix?: string; symbolPrefix?: string; createdByUserId: string; memo?: string; }): Promise<{ tokenId: string; id: string; name: string; symbol: string; }> {
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
          createdByUserId: params.createdByUserId,
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


