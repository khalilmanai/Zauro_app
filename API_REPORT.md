# Zauro Marketplace Backend API Report

## 🏗️ Architecture Overview

The Zauro Marketplace is a blockchain-based animal marketplace built with **NestJS**, **PostgreSQL**, **Prisma ORM**, **Hedera Hashgraph**, and **Supabase**. Animals are represented as NFTs on the Hedera blockchain, enabling secure peer-to-peer trading.

### Technology Stack
- **Backend Framework**: NestJS (Latest)
- **Database**: PostgreSQL with Prisma ORM
- **Blockchain**: Hedera Hashgraph SDK
- **File Storage**: Supabase Storage
- **Authentication**: JWT with refresh tokens
- **Email**: SMTP (Nodemailer)
- **SMS**: Twilio
- **Documentation**: Swagger/OpenAPI
- **Containerization**: Docker & Docker Compose
- **Cache**: Redis
- **Reverse Proxy**: Nginx

## 📁 Module Architecture

### Core Modules

#### 1. **AuthModule** (`src/auth/`)
- **Purpose**: User authentication and authorization
- **Features**:
  - User registration and login
  - JWT access and refresh tokens
  - Role-based access control (Admin, HR/Manager, Employee/Trader)
  - Password hashing with bcrypt
  - Refresh token rotation

#### 2. **OtpModule** (`src/otp/`)
- **Purpose**: One-time password management
- **Features**:
  - Secure OTP generation (6-digit, time-limited)
  - OTP validation and expiration
  - Automatic cleanup of expired OTPs

#### 3. **MailModule** (`src/mail/`)
- **Purpose**: Email notifications
- **Features**:
  - Password reset emails
  - Welcome emails
  - Trade notification emails
  - SMTP configuration

#### 4. **SmsModule** (`src/sms/`)
- **Purpose**: SMS notifications
- **Features**:
  - Password reset SMS
  - Welcome SMS
  - Trade notification SMS
  - Twilio integration

#### 5. **WalletModule** (`src/wallet/`)
- **Purpose**: Hedera wallet management
- **Features**:
  - Custodial wallet creation
  - Encrypted private key storage
  - HBAR and ZAU token balance queries
  - Hedera account management
  - NFT collection management
  - NFT minting, transferring, and burning
  - Collection status monitoring
  - User NFT portfolio management

#### 6. **AnimalsModule** (`src/animals/`)
- **Purpose**: Animal NFT management
- **Features**:
  - Animal registration and metadata
  - NFT minting on Hedera
  - Image and vet record uploads
  - Animal ownership tracking

#### 7. **TradesModule** (`src/trades/`)
- **Purpose**: Marketplace trading
- **Features**:
  - Animal listing for sale
  - Atomic swap execution
  - Trade status management
  - Smart contract integration

#### 8. **SupabaseModule** (`src/supabase/`)
- **Purpose**: File storage management
- **Features**:
  - Image uploads (animal photos)
  - Document uploads (vet records)
  - File type validation
  - Public URL generation

## 🗄️ Database Schema

### Models

#### User
```typescript
{
  id: string (CUID)
  email: string (unique)
  phone?: string (unique)
  password: string (hashed)
  firstName: string
  lastName: string
  role: UserRole (ADMIN | HR_MANAGER | EMPLOYEE_TRADER)
  isActive: boolean
  isVerified: boolean
  createdAt: DateTime
  updatedAt: DateTime
  lastLoginAt?: DateTime
}
```

#### Wallet
```typescript
{
  id: string (CUID)
  userId: string (unique)
  hederaAccountId: string (unique)
  encryptedPrivateKey: string
  publicKey: string
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### Animal
```typescript
{
  id: string (CUID)
  name: string
  species: AnimalSpecies (DOG | CAT | BIRD | FISH | REPTILE | OTHER)
  breed?: string
  age?: number
  description?: string
  tokenId?: string (unique)
  tokenSerialNumber?: string
  imageUrl?: string
  vetRecordUrl?: string
  aiPredictionValue?: Decimal
  ownerId: string
  isListed: boolean
  createdAt: DateTime
  updatedAt: DateTime
}
```

#### Trade
```typescript
{
  id: string (CUID)
  animalId: string
  sellerId: string
  buyerId?: string
  price: Decimal
  currency: string (default: "HBAR")
  status: TradeStatus (PENDING | LISTED | IN_PROGRESS | COMPLETED | CANCELLED | FAILED)
  contractAddress?: string
  transactionHash?: string
  createdAt: DateTime
  updatedAt: DateTime
  completedAt?: DateTime
}
```

#### Otp
```typescript
{
  id: string (CUID)
  userId: string
  code: string
  type: OtpType (PASSWORD_RESET | EMAIL_VERIFICATION | PHONE_VERIFICATION)
  isUsed: boolean
  expiresAt: DateTime
  createdAt: DateTime
  usedAt?: DateTime
}
```

## 🔗 API Endpoints

### Authentication (`/auth`)

#### POST `/auth/register`
Register a new user
```json
{
  "email": "user@example.com",
  "phone": "+1234567890",
  "password": "securepassword",
  "firstName": "John",
  "lastName": "Doe"
}
```

#### POST `/auth/login`
Login user
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

#### POST `/auth/refresh`
Refresh access token (requires Bearer token)

#### POST `/auth/forgot-password/request`
Request password reset OTP
```json
{
  "email": "user@example.com"
  // OR
  "phone": "+1234567890"
}
```

#### POST `/auth/forgot-password/verify`
Verify OTP
```json
{
  "code": "123456",
  "email": "user@example.com"
}
```

#### POST `/auth/forgot-password/reset`
Reset password with OTP
```json
{
  "code": "123456",
  "newPassword": "newsecurepassword",
  "email": "user@example.com"
}
```

#### GET `/auth/profile`
Get user profile (requires Bearer token)

### Wallet Management (`/wallets`)

#### POST `/wallets/create`
Create wallet for authenticated user (requires Bearer token)

#### GET `/wallets/my-wallet`
Get authenticated user's wallet (requires Bearer token)

#### GET `/wallets/my-wallet/balance`
Get authenticated user's wallet balance (requires Bearer token)

#### POST `/wallets/transfer/hbar`
Transfer HBAR between accounts (requires Bearer token)
```json
{
  "toAccountId": "0.0.123456",
  "amount": "10.0"
}
```

#### GET `/wallets/{id}`
Get wallet by ID (requires Bearer token)

#### GET `/wallets/{id}/balance`
Get wallet balance by ID (requires Bearer token)

### NFT Collection Management (`/wallets/collections`)

#### POST `/wallets/collections`
Create new NFT collection (requires Bearer token)
```json
{
  "name": "Zauro Animals",
  "symbol": "ZAC",
  "maxSupply": 1000000
}
```

#### GET `/wallets/collections/status`
Get current collection status (requires Bearer token)

#### GET `/wallets/collections/nfts`
Get all NFTs in current collection (requires Bearer token)

### NFT Operations (`/wallets`)

#### POST `/wallets/mint-nft`
Mint new NFT (requires Bearer token)
```json
{
  "tokenId": "0.0.123456",
  "metadata": {
    "name": "Fluffy",
    "species": "Dog",
    "breed": "Golden Retriever",
    "age": 2,
    "imageUrl": "https://example.com/fluffy.jpg"
  }
}
```

#### POST `/wallets/transfer-nft`
Transfer NFT to another account (requires Bearer token)
```json
{
  "tokenId": "0.0.123456",
  "serialNumber": "1",
  "toAccountId": "0.0.789012"
}
```

#### DELETE `/wallets/burn-nft`
Burn NFT (requires Bearer token)
```json
{
  "tokenId": "0.0.123456",
  "serialNumber": "1"
}
```

#### GET `/wallets/my-nfts`
Get user's owned NFTs (requires Bearer token)

### Hedera Standalone Service (Port 3001)

The Hedera service runs as a separate microservice on port 3001, providing direct blockchain operations.

#### POST `/create-wallet`
Create new Hedera wallet
```json
{
  "response": {
    "accountId": "0.0.123456",
    "privateKey": "302e020100300506032b657004220420..."
  }
}
```

#### POST `/create-collection`
Create NFT collection
```json
{
  "name": "DemoNFT",
  "symbol": "DNFT",
  "maxSupply": 1000000
}
```

#### POST `/mint-nft`
Mint NFT with metadata
```json
{
  "tokenId": "0.0.123456",
  "metadata": {
    "name": "Animal Name",
    "species": "Dog",
    "breed": "Golden Retriever"
  },
  "ownerAccountId": "0.0.789012",
  "ownerPrivateKey": "302e020100300506032b657004220420..."
}
```

#### POST `/transfer-nft`
Transfer NFT between accounts
```json
{
  "tokenId": "0.0.123456",
  "serialNumber": "1",
  "fromAccountId": "0.0.789012",
  "fromPrivateKey": "302e020100300506032b657004220420...",
  "toAccountId": "0.0.345678"
}
```

#### GET `/collection-status`
Get current collection status
```json
{
  "tokenId": "0.0.123456",
  "name": "DemoNFT",
  "symbol": "DNFT",
  "nftCount": 1500,
  "maxSupply": 1000000,
  "usagePercentage": 0.15,
  "status": "ACTIVE"
}
```

#### GET `/collection-nfts`
Get all NFTs in current collection

#### GET `/nfts/:accountId`
Get NFTs owned by specific account

#### GET `/nfts`
Get all NFTs minted by operator

#### GET `/wallets/:id`
Get wallet by ID

#### GET `/wallets/:id/balance`
Get wallet balance by wallet ID

### Animal Management (`/animals`)

#### POST `/animals`
Create animal and mint NFT (requires Bearer token)
```json
{
  "name": "Buddy",
  "species": "DOG",
  "breed": "Golden Retriever",
  "age": 3,
  "description": "Friendly and energetic dog",
  "aiPredictionValue": 1500.00
}
```

#### GET `/animals`
Get all animals with pagination
- Query params: `page`, `limit`, `ownerId`

#### GET `/animals/:id`
Get animal by ID

#### PATCH `/animals/:id`
Update animal metadata (requires Bearer token)

#### DELETE `/animals/:id`
Delete animal and burn NFT (requires Bearer token)

#### POST `/animals/:id/upload-image`
Upload animal image (requires Bearer token)

#### POST `/animals/:id/upload-vet-record`
Upload vet record (requires Bearer token)

### Trading (`/trades`)

#### POST `/trades/list`
List animal for trade (requires Bearer token)
```json
{
  "animalId": "animal_id_here",
  "price": 100.50,
  "currency": "HBAR"
}
```

#### GET `/trades`
Get all trades with pagination
- Query params: `page`, `limit`, `status`

#### GET `/trades/:id`
Get trade by ID

#### POST `/trades/buy/:id`
Buy animal (initiate trade) (requires Bearer token)

#### POST `/trades/execute/:id`
Execute trade (complete atomic swap) (requires Bearer token)

#### POST `/trades/cancel/:id`
Cancel trade (requires Bearer token)

## 🔐 Security Features

### Authentication & Authorization
- JWT-based authentication with access and refresh tokens
- Role-based access control (RBAC)
- Password hashing with bcrypt (12 rounds)
- Refresh token rotation for enhanced security

### Data Protection
- Private keys encrypted with AES-256
- Input validation with class-validator
- Rate limiting with NestJS Throttler
- CORS enabled for cross-origin requests

### Blockchain Security
- Hedera Hashgraph for secure transactions
- Atomic swaps for trade execution
- NFT minting and burning capabilities
- Transaction hash tracking

## 🌐 Environment Variables

### Required Environment Variables

```bash
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/zauro_db"

# JWT Configuration
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
JWT_REFRESH_SECRET="your-super-secret-refresh-jwt-key-change-this-in-production"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Application
NODE_ENV="development"
PORT=3000
API_PREFIX="api/v1"

# Email (SMTP)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM="Zauro Marketplace <noreply@zauro.com>"

# SMS (Twilio)
TWILIO_ACCOUNT_SID="your-twilio-account-sid"
TWILIO_AUTH_TOKEN="your-twilio-auth-token"
TWILIO_PHONE_NUMBER="+1234567890"

# Hedera Blockchain
HEDERA_ACCOUNT_ID="0.0.123456"
HEDERA_PRIVATE_KEY="302e020100300506032b657004220420..."
HEDERA_NETWORK="testnet"
HEDERA_MIRROR_NODE_URL="https://testnet.mirrornode.hedera.com"

# Supabase Storage
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"

# Encryption
ENCRYPTION_KEY="your-32-character-encryption-key"

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=10

# OTP Configuration
OTP_EXPIRES_IN_MINUTES=10
OTP_LENGTH=6

# File Upload
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES="image/jpeg,image/png,image/gif,application/pdf"
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v18 or higher)
- PostgreSQL database
- Hedera testnet account
- Supabase project
- Twilio account (for SMS)
- SMTP email service

### Installation

1. **Clone and install dependencies**
```bash
npm install
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your actual values
```

3. **Set up database**
```bash
npx prisma migrate dev
npx prisma generate
```

4. **Start the application**
```bash
npm run start:dev
```

5. **Access API documentation**
- API: http://localhost:3000
- Swagger Docs: http://localhost:3000/api/docs

## 📊 API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Paginated Response
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error information",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 🔄 Trade Flow

1. **Animal Registration**: User creates animal profile and mints NFT
2. **Listing**: User lists animal for sale with price
3. **Purchase**: Buyer initiates purchase (trade status: IN_PROGRESS)
4. **Execution**: Atomic swap executed on Hedera blockchain
5. **Completion**: NFT transferred, payment processed, notifications sent

## 🛡️ Security Considerations

- All sensitive data encrypted at rest
- Private keys never stored in plain text
- Rate limiting prevents abuse
- Input validation prevents injection attacks
- CORS configured for secure cross-origin requests
- JWT tokens have short expiration times
- Refresh token rotation implemented

## 📈 Scalability Features

- Modular architecture for easy scaling
- Database connection pooling with Prisma
- File storage with Supabase (CDN-ready)
- Blockchain transactions for immutable records
- Microservice-ready architecture

## 🔧 Development Notes

- Uses TypeScript for type safety
- Comprehensive error handling
- Logging with NestJS Logger
- Swagger documentation auto-generated
- Database migrations with Prisma
- Environment-based configuration

---

**Built with ❤️ for the Zauro Marketplace**

*This API provides a complete backend solution for a blockchain-based animal marketplace, enabling secure NFT trading on the Hedera Hashgraph network.*
