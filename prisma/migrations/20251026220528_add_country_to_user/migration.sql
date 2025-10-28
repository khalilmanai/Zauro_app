/*
  Warnings:

  - The values [DOG,CAT,BIRD,FISH,REPTILE] on the enum `AnimalSpecies` will be removed. If these variants are still used in the database, this will fail.
  - A unique constraint covering the columns `[did]` on the table `users` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "public"."AnimalGender" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "public"."AnimalStatus" AS ENUM ('PENDING_EXPERT_REVIEW', 'EXPERT_APPROVED', 'EXPERT_REJECTED', 'LISTED', 'MINTED');

-- CreateEnum
CREATE TYPE "public"."CredentialType" AS ENUM ('KYC', 'REPUTATION', 'VETERINARY', 'IDENTITY', 'BUSINESS_LICENSE');

-- CreateEnum
CREATE TYPE "public"."CredentialStatus" AS ENUM ('ACTIVE', 'REVOKED', 'EXPIRED', 'PENDING');

-- CreateEnum
CREATE TYPE "public"."CollectionStatus" AS ENUM ('ACTIVE', 'DISABLED');

-- AlterEnum
BEGIN;
CREATE TYPE "public"."AnimalSpecies_new" AS ENUM ('COW', 'GOAT', 'SHEEP', 'OTHER');
ALTER TABLE "public"."animals" ALTER COLUMN "species" TYPE "public"."AnimalSpecies_new" USING ("species"::text::"public"."AnimalSpecies_new");
ALTER TYPE "public"."AnimalSpecies" RENAME TO "AnimalSpecies_old";
ALTER TYPE "public"."AnimalSpecies_new" RENAME TO "AnimalSpecies";
DROP TYPE "public"."AnimalSpecies_old";
COMMIT;

-- AlterTable
ALTER TABLE "public"."animals" ADD COLUMN     "expertReviewComment" TEXT,
ADD COLUMN     "expertReviewDate" TIMESTAMP(3),
ADD COLUMN     "expertReviewedBy" TEXT,
ADD COLUMN     "gender" "public"."AnimalGender" NOT NULL DEFAULT 'MALE',
ADD COLUMN     "status" "public"."AnimalStatus" NOT NULL DEFAULT 'PENDING_EXPERT_REVIEW';

-- AlterTable
ALTER TABLE "public"."users" ADD COLUMN     "country" TEXT,
ADD COLUMN     "did" TEXT,
ADD COLUMN     "didDocument" JSONB,
ADD COLUMN     "didPrivateKey" TEXT;

-- CreateTable
CREATE TABLE "public"."credentials" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."CredentialType" NOT NULL,
    "status" "public"."CredentialStatus" NOT NULL DEFAULT 'ACTIVE',
    "issuerDid" TEXT NOT NULL,
    "subjectDid" TEXT NOT NULL,
    "credentialId" TEXT NOT NULL,
    "credentialData" JSONB NOT NULL,
    "signature" TEXT,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "credentials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."collections" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "symbol" TEXT NOT NULL,
    "tokenId" TEXT NOT NULL,
    "treasuryAccountId" TEXT NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "status" "public"."CollectionStatus" NOT NULL DEFAULT 'ACTIVE',
    "maxSupply" INTEGER,
    "autoRotate" BOOLEAN NOT NULL DEFAULT true,
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "collections_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "credentials_credentialId_key" ON "public"."credentials"("credentialId");

-- CreateIndex
CREATE UNIQUE INDEX "collections_tokenId_key" ON "public"."collections"("tokenId");

-- CreateIndex
CREATE UNIQUE INDEX "users_did_key" ON "public"."users"("did");

-- AddForeignKey
ALTER TABLE "public"."credentials" ADD CONSTRAINT "credentials_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
