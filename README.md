# 🐾 Zauro Marketplace Backend - Comprehensive Project Overview

## 📋 Executive Summary

The **Zauro Marketplace Backend** is a sophisticated blockchain-based animal trading platform built with **NestJS**, **PostgreSQL**, **Hedera Hashgraph**, and **Supabase**. The system enables users to register animals as NFTs on the blockchain and trade them through a secure, decentralized marketplace with atomic swap functionality.

### 🎯 Core Value Proposition
- **Blockchain-Native**: Animals are represented as NFTs on Hedera Hashgraph, ensuring immutable ownership records
- **Secure Trading**: Atomic swap execution prevents fraud and ensures fair transactions
- **Comprehensive Management**: Full lifecycle management from animal registration to trading completion
- **Enterprise-Ready**: Role-based access control, comprehensive security, and scalable architecture

---

## 🏗️ Technical Architecture

### Technology Stack
| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend Framework** | NestJS (TypeScript) | Modular, scalable REST API |
| **Database** | PostgreSQL + Prisma ORM | Relational data storage with type-safe queries |
| **Blockchain** | Hedera Hashgraph SDK | NFT minting, transfers, and atomic swaps |
| **File Storage** | Supabase Storage | Animal images and veterinary records |
| **Authentication** | JWT with refresh tokens | Secure user authentication |
| **Email Service** | MailerSend | Transactional emails and notifications |
| **SMS Service** | Twilio | SMS notifications and OTP delivery |
| **Documentation** | Swagger/OpenAPI | Auto-generated API documentation |
| **Security** | bcrypt, AES-256, Rate limiting | Data protection and security |

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   NestJS API    │    │   Hedera        │
│   Application   │◄──►│   (Backend)     │◄──►│   Blockchain    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        │
                       ┌─────────────────┐             │
                       │   PostgreSQL    │             │
                       │   + Prisma ORM  │             │
                       └─────────────────┘             │
                              │                        │
                              ▼                        │
                       ┌─────────────────┐             │
                       │   Supabase      │             │
                       │   Storage       │             │
                       └─────────────────┘             │
                              │                        │
                              ▼                        │
                       ┌─────────────────┐             │
                       │   External      │◄────────────┘
                       │   Services      │
                       │   (SMTP/Twilio) │
                       └─────────────────┘
```

---

## 🗄️ Database Schema & Models

### Core Entities

#### 👤 User Model
```typescript
{
  id: string (CUID)           // Primary key
  email: string (unique)      // User email address
  phone?: string (unique)     // Optional phone number
  password: string (hashed)   // bcrypt hashed password
  firstName: string          // User's first name
  lastName: string           // User's last name
  role: UserRole             // ADMIN | HR_MANAGER | EMPLOYEE_TRADER
  isActive: boolean          // Account status
  isVerified: boolean        // Email/phone verification status
  createdAt: DateTime        // Registration timestamp
  updatedAt: DateTime        // Last modification timestamp
  lastLoginAt?: DateTime     // Last login tracking
}
```

#### 💰 Wallet Model
```typescript
{
  id: string (CUID)              // Primary key
  userId: string (unique)        // Foreign key to User
  hederaAccountId: string (unique) // Hedera account identifier
  encryptedPrivateKey: string    // AES-256 encrypted private key
  publicKey: string             // Hedera public key
  createdAt: DateTime           // Creation timestamp
  updatedAt: DateTime           // Last modification timestamp
}
```

#### 🐾 Animal Model
```typescript
{
  id: string (CUID)                    // Primary key
  name: string                         // Animal name
  species: AnimalSpecies              // DOG | CAT | BIRD | FISH | REPTILE | OTHER
  breed?: string                      // Animal breed (optional)
  age?: number                        // Animal age in years
  description?: string                // Detailed description
  tokenId?: string (unique)           // Hedera NFT token ID
  tokenSerialNumber?: string          // NFT serial number
  imageUrl?: string                   // Supabase image URL
  vetRecordUrl?: string              // Veterinary record URL
  aiPredictionValue?: Decimal        // AI-predicted market value
  ownerId: string                    // Foreign key to User
  isListed: boolean                  // Currently listed for trade
  createdAt: DateTime                // Creation timestamp
  updatedAt: DateTime                // Last modification timestamp
}
```

#### 🔄 Trade Model
```typescript
{
  id: string (CUID)              // Primary key
  animalId: string               // Foreign key to Animal
  sellerId: string               // Foreign key to User (seller)
  buyerId?: string               // Foreign key to User (buyer, optional)
  price: Decimal                 // Trade price
  currency: string               // HBAR or ZAU token
  status: TradeStatus            // PENDING | LISTED | IN_PROGRESS | COMPLETED | CANCELLED | FAILED
  contractAddress?: string       // Smart contract address (future use)
  transactionHash?: string       // Blockchain transaction hash
  createdAt: DateTime           // Trade creation timestamp
  updatedAt: DateTime           // Last modification timestamp
  completedAt?: DateTime        // Trade completion timestamp
}
```

#### 🔐 OTP Model
```typescript
{
  id: string (CUID)          // Primary key
  userId: string             // Foreign key to User
  code: string               // 6-digit OTP code
  type: OtpType             // PASSWORD_RESET | EMAIL_VERIFICATION | PHONE_VERIFICATION
  isUsed: boolean           // Usage status
  expiresAt: DateTime       // Expiration timestamp
  createdAt: DateTime       // Creation timestamp
  usedAt?: DateTime         // Usage timestamp
}
```

---

## 🔧 Core Features & Modules

### 1. 🔐 Authentication Module (`src/auth/`)

**Purpose**: Comprehensive user authentication and authorization system

**Key Features**:
- **User Registration**: Email/phone validation, password hashing (bcrypt with 12 rounds)
- **Secure Login**: Credential validation with rate limiting
- **JWT Token Management**: Access tokens (15min) + refresh tokens (7 days) with rotation
- **Password Recovery**: OTP-based reset via email or SMS
- **Role-Based Access Control**: Admin, HR/Manager, Employee/Trader roles
- **Session Management**: Last login tracking and active session management

**Security Measures**:
- Password complexity validation
- Account lockout after failed attempts
- Token blacklisting capabilities
- Secure token storage and transmission

**API Endpoints**:
- `POST /auth/register` - User registration
- `POST /auth/login` - User authentication
- `POST /auth/refresh` - Token refresh
- `POST /auth/forgot-password/request` - Request password reset OTP
- `POST /auth/forgot-password/verify` - Verify OTP code
- `POST /auth/forgot-password/reset` - Reset password with OTP
- `GET /auth/profile` - Get user profile

### 2. 🐾 Animals Module (`src/animals/`)

**Purpose**: Complete animal NFT lifecycle management

**Key Features**:
- **Animal Registration**: Comprehensive metadata collection (species, breed, age, description)
- **NFT Minting**: Automatic NFT creation on Hedera blockchain upon animal registration
- **File Management**: Image and veterinary record uploads via Supabase
- **AI Integration**: AI-predicted market value calculation and storage
- **Ownership Tracking**: Immutable ownership records on blockchain
- **Listing Management**: Enable/disable animals for trading

**Blockchain Integration**:
- Automatic NFT minting with metadata
- Ownership transfer via atomic swaps
- NFT burning when animals are removed
- Transaction hash tracking for all operations

**API Endpoints**:
- `POST /animals` - Create animal and mint NFT
- `GET /animals` - List all animals (paginated, filterable)
- `GET /animals/:id` - Get animal details
- `PATCH /animals/:id` - Update animal metadata
- `DELETE /animals/:id` - Delete animal and burn NFT
- `POST /animals/:id/upload-image` - Upload animal image
- `POST /animals/:id/upload-vet-record` - Upload veterinary records

### 3. 🔄 Trading Module (`src/trades/`)

**Purpose**: Secure peer-to-peer animal trading with blockchain execution

**Key Features**:
- **Trade Creation**: List animals for sale with price and currency specification
- **Trade Discovery**: Browse available animals with filtering and pagination
- **Purchase Initiation**: Buyer commits to purchase, locking the trade
- **Atomic Swap Execution**: Simultaneous NFT and payment transfer
- **Trade Status Tracking**: Real-time status updates throughout trade lifecycle
- **Notification System**: Email and SMS notifications for all trade events

**Trade Flow**:
1. **Listing**: Seller lists animal with price (HBAR or ZAU tokens)
2. **Discovery**: Buyers browse available animals
3. **Purchase**: Buyer initiates purchase, trade status becomes "IN_PROGRESS"
4. **Execution**: Atomic swap transfers NFT to buyer and payment to seller
5. **Completion**: Ownership updated, notifications sent, trade marked "COMPLETED"

**API Endpoints**:
- `POST /trades/list` - List animal for trade
- `GET /trades` - Get all trades (paginated, filterable by status)
- `GET /trades/:id` - Get trade details
- `POST /trades/buy/:id` - Initiate purchase
- `POST /trades/execute/:id` - Execute atomic swap
- `POST /trades/cancel/:id` - Cancel trade

### 4. 💰 Wallet Module (`src/wallet/`)

**Purpose**: Hedera blockchain wallet management with secure key storage

**Key Features**:
- **Custodial Wallet Creation**: Automatic Hedera account generation for users
- **Secure Key Storage**: AES-256 encryption of private keys
- **Balance Queries**: Real-time HBAR and ZAU token balance retrieval
- **Transaction Management**: HBAR transfers and NFT operations
- **Multi-Currency Support**: Native HBAR and custom ZAU token support

**Security Features**:
- Private keys never stored in plaintext
- Encryption key management via environment variables
- Secure key derivation and storage
- Transaction signing with encrypted keys

**API Endpoints**:
- `POST /wallets/create` - Create new wallet
- `GET /wallets/my-wallet` - Get user's wallet
- `GET /wallets/my-wallet/balance` - Get wallet balance
- `GET /wallets/:id` - Get wallet by ID
- `GET /wallets/:id/balance` - Get wallet balance by ID

### 5. 📧 Notification System

#### Mail Module (`src/mail/`)
**Purpose**: Transactional email delivery via SMTP

**Features**:
- Password reset OTP emails
- Welcome emails for new users
- Trade notification emails
- HTML email templates with responsive design
- Error handling and retry logic

#### SMS Module (`src/sms/`)
**Purpose**: SMS notifications via Twilio integration

**Features**:
- Password reset OTP via SMS
- Welcome messages for new users
- Trade notifications via SMS
- International SMS support
- Delivery status tracking

### 6. 🔐 OTP Module (`src/otp/`)

**Purpose**: One-time password management for secure operations

**Key Features**:
- **Secure OTP Generation**: 6-digit cryptographically secure codes
- **Multiple OTP Types**: Password reset, email verification, phone verification
- **Expiration Management**: Configurable expiration times (default: 10 minutes)
- **Usage Tracking**: Single-use enforcement with usage timestamps
- **Automatic Cleanup**: Expired OTP removal to maintain database hygiene

**Security Measures**:
- Time-based expiration
- Single-use enforcement
- Rate limiting on OTP generation
- Secure random number generation

### 7. 📁 File Storage Module (`src/supabase/`)

**Purpose**: Secure file storage and management via Supabase

**Key Features**:
- **Multi-Type Support**: Images (JPEG, PNG, GIF) and documents (PDF)
- **File Validation**: Type, size, and content validation
- **Organized Storage**: User-based file organization
- **Public URL Generation**: Direct access URLs for uploaded files
- **File Tracking**: Database records of all uploads with metadata

**Storage Buckets**:
- `animal-images`: Animal photographs and visual content
- `vet-records`: Veterinary documents and health records

---

## 🔒 Security Architecture

### Authentication & Authorization
- **JWT-Based Authentication**: Secure token-based authentication with short-lived access tokens
- **Refresh Token Rotation**: Enhanced security with automatic token refresh
- **Role-Based Access Control (RBAC)**: Three-tier permission system
- **Password Security**: bcrypt hashing with 12 rounds, complexity requirements

### Data Protection
- **Encryption at Rest**: AES-256 encryption for sensitive data (private keys)
- **Secure Communication**: HTTPS enforcement, secure headers
- **Input Validation**: Comprehensive validation with class-validator
- **SQL Injection Prevention**: Prisma ORM with parameterized queries

### Blockchain Security
- **Private Key Management**: Never stored in plaintext, AES-256 encrypted
- **Transaction Signing**: Secure signing with encrypted private keys
- **Atomic Operations**: Prevents partial transaction completion
- **Immutable Records**: Blockchain-based ownership and transaction history

### Infrastructure Security
- **Rate Limiting**: Configurable request rate limiting (10 req/min default)
- **CORS Configuration**: Secure cross-origin resource sharing
- **Environment Isolation**: Separate configurations for development/production
- **Error Handling**: Secure error messages without sensitive information exposure

---

## 🌐 API Architecture

### RESTful Design Principles
- **Resource-Based URLs**: Clear, intuitive endpoint structure
- **HTTP Method Semantics**: Proper use of GET, POST, PATCH, DELETE
- **Status Code Standards**: Appropriate HTTP status codes for all responses
- **Consistent Response Format**: Standardized success/error response structure

### Response Format Standards

#### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { /* response data */ },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### Paginated Response
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [ /* array of items */ ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error information",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### API Documentation
- **Swagger/OpenAPI Integration**: Auto-generated documentation
- **Interactive API Explorer**: Live API testing interface
- **Comprehensive Examples**: Request/response examples for all endpoints
- **Authentication Documentation**: Clear authentication requirements

---

## 🔄 Business Logic & Workflows

### Animal Registration & NFT Minting Workflow
1. **User Registration**: User creates account and gets authenticated
2. **Wallet Creation**: Automatic Hedera wallet generation with encrypted private key storage
3. **Animal Registration**: User provides animal metadata and uploads files
4. **File Processing**: Images and vet records uploaded to Supabase with validation
5. **NFT Minting**: Animal data converted to NFT metadata and minted on Hedera
6. **Database Update**: Animal record updated with NFT token ID and serial number
7. **Confirmation**: User receives confirmation with NFT details

### Trading Workflow
1. **Listing Creation**: Animal owner lists animal for trade with price
2. **Market Discovery**: Buyers browse available animals with filtering
3. **Purchase Initiation**: Buyer commits to purchase, trade status becomes "IN_PROGRESS"
4. **Balance Verification**: System verifies buyer has sufficient funds
5. **Atomic Swap Preparation**: System prepares simultaneous NFT and payment transfer
6. **Blockchain Execution**: NFT transferred to buyer, payment to seller
7. **Ownership Update**: Database updated with new ownership
8. **Notifications**: Both parties receive trade completion notifications

### Password Recovery Workflow
1. **Reset Request**: User provides email or phone number
2. **User Verification**: System verifies user exists
3. **OTP Generation**: 6-digit code generated with 10-minute expiration
4. **Delivery**: OTP sent via email or SMS based on request
5. **Verification**: User provides OTP for verification
6. **Password Reset**: User provides new password, system updates with bcrypt hash
7. **Confirmation**: User receives confirmation of password change

---

## 🚀 Performance & Scalability

### Database Optimization
- **Prisma ORM**: Type-safe queries with automatic optimization
- **Connection Pooling**: Efficient database connection management
- **Indexing Strategy**: Optimized indexes on frequently queried fields
- **Query Optimization**: Efficient joins and data fetching patterns

### Caching Strategy
- **Application-Level Caching**: In-memory caching for frequently accessed data
- **CDN Integration**: Supabase CDN for file delivery
- **Database Query Caching**: Prisma query result caching
- **API Response Caching**: Cacheable responses for static data

### Scalability Features
- **Modular Architecture**: Independent module scaling
- **Microservice Ready**: Easy decomposition into microservices
- **Load Balancer Compatible**: Stateless design for horizontal scaling
- **Database Scaling**: PostgreSQL read replicas and sharding support

---

## 🐳 Docker Setup & Deployment

### Quick Start with Docker
The project is fully containerized and ready for development and production deployment.

#### Prerequisites
- Docker Desktop installed and running
- Git (to clone the repository)

#### Development Setup
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd Zauro_app
   ```

2. **Create environment file**:
   ```bash
   cp env.example .env
   # Edit .env with your configuration values
   ```

3. **Start all services**:
   ```bash
   docker-compose up --build
   ```

4. **Run database migrations**:
   ```bash
   docker-compose exec backend npx prisma migrate deploy
   ```

5. **Access the application**:
   - Backend API: http://localhost:3000
   - Hedera Service: http://localhost:3001
   - API Documentation: http://localhost:3000/api/docs
   - PostgreSQL: localhost:5432

#### Services Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   NestJS        │    │   Hedera        │
│   (Flutter)     │◄──►│   Backend       │◄──►│   Service       │
│   Port: 3000    │    │   Port: 3000    │    │   Port: 3001    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │                        │
                              ▼                        ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   PostgreSQL    │    │   Hedera        │
                       │   Port: 5432     │    │   Testnet       │
                       └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Redis         │
                       │   Port: 6379    │
                       └─────────────────┘
```

### Docker Services

#### Backend Service (NestJS)
- **Port**: 3000
- **Features**: Full REST API, JWT authentication, Prisma ORM
- **Health Check**: `/api/v1/health`
- **Development Mode**: Hot reloading enabled

#### Hedera Service
- **Port**: 3001
- **Features**: Blockchain operations, NFT management, wallet creation
- **Health Check**: `/collection-status`
- **Auto-collection Management**: Creates new NFT collections automatically

#### PostgreSQL Database
- **Port**: 5432
- **Features**: Relational data storage, Prisma migrations
- **Health Check**: Built-in PostgreSQL health check
- **Data Persistence**: Docker volume for data persistence

#### Redis Cache
- **Port**: 6379
- **Features**: Session storage, caching, rate limiting
- **Health Check**: Built-in Redis health check

#### Nginx Reverse Proxy
- **Port**: 80/443
- **Features**: Load balancing, SSL termination, static file serving
- **Configuration**: Development and production configs included

### Environment Configuration

#### Required Environment Variables
```bash
# Database
DATABASE_URL="postgresql://zauro_user:zauro_password@postgres:5432/zauro_db"
POSTGRES_DB="zauro_db"
POSTGRES_USER="zauro_user"
POSTGRES_PASSWORD="zauro_password"

# JWT Security
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_REFRESH_SECRET="your-super-secret-refresh-jwt-key-change-in-production"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Hedera Blockchain
HEDERA_OPERATOR_ID="0.0.123456"
HEDERA_OPERATOR_KEY="302e020100300506032b657004220420..."
HEDERA_NETWORK="testnet"
HEDERA_MIRROR_NODE_URL="https://testnet.mirrornode.hedera.com"
HEDERA_SUPPLY_KEY="302e020100300506032b657004220420..."
HEDERA_COLLECTION_TOKEN_ID="0.0.123456"

# Supabase Storage
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"

# Communication Services
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURE="false"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM="noreply@yourdomain.com"

TWILIO_ACCOUNT_SID="your-twilio-account-sid"
TWILIO_AUTH_TOKEN="your-twilio-auth-token"
TWILIO_PHONE_NUMBER="+1234567890"

# Security
ENCRYPTION_KEY="your-32-character-encryption-key"

# Performance
THROTTLE_TTL="60"
THROTTLE_LIMIT="10"
OTP_EXPIRES_IN_MINUTES="10"
OTP_LENGTH="6"
MAX_FILE_SIZE="10485760"
ALLOWED_FILE_TYPES="image/jpeg,image/png,image/gif,application/pdf"
```

### Development Environment
- **TypeScript**: Full type safety and modern JavaScript features
- **Hot Reload**: Automatic server restart during development
- **Environment Configuration**: Separate configs for dev/staging/production
- **Database Migrations**: Prisma-managed schema migrations
- **Comprehensive Testing**: Unit and integration test suites

### Production Deployment
- **Container Ready**: Docker support for containerized deployment
- **Environment Variables**: Secure configuration management
- **Health Checks**: Built-in health monitoring endpoints
- **Logging**: Comprehensive logging with configurable levels
- **Error Monitoring**: Structured error reporting and tracking

### CI/CD Pipeline Support
- **Automated Testing**: Test execution on code changes
- **Build Automation**: Automatic build and deployment processes
- **Database Migration**: Automated schema updates
- **Environment Promotion**: Staged deployment process

---

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### 1. Database Connection Issues
**Error**: `The table 'public.users' does not exist in the current database`

**Solution**:
```bash
# Run database migrations
docker-compose exec backend npx prisma migrate deploy

# Or reset the database completely
docker-compose exec backend npx prisma migrate reset
```

#### 2. Backend Container Won't Start
**Error**: `Error: Cannot find module '/app/dist/main'`

**Solutions**:
- Ensure TypeScript config files are copied to container
- Check if development mode is enabled (`npm run start:dev`)
- Verify all dependencies are installed

#### 3. Hedera Service Health Check Fails
**Error**: `container zauro-hedera is unhealthy`

**Solutions**:
- Check if Hedera credentials are properly set in `.env`
- Verify Hedera service is responding on port 3001
- Check Hedera service logs: `docker-compose logs hedera-service`

#### 4. Permission Denied Errors
**Error**: `EACCES: permission denied, rmdir '/app/dist'`

**Solution**:
- Ensure proper file ownership in Dockerfile
- Check if `chown` command is executed before switching users

#### 5. Frontend Connection Issues
**Error**: Frontend can't connect to backend

**Solutions**:
- Verify backend is running on port 3000
- Check if CORS is properly configured
- Ensure API base URL is correct in frontend config

#### 6. Environment Variable Issues
**Error**: `The "HEDERA_OPERATOR_ID" variable is not set`

**Solutions**:
- Create `.env` file from `env.example`
- Set all required environment variables
- Restart containers after changing environment variables

### Docker Commands Reference

#### Container Management
```bash
# Start all services
docker-compose up --build

# Start specific service
docker-compose up backend

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs backend
docker-compose logs hedera-service

# Execute commands in running container
docker-compose exec backend npx prisma migrate deploy
docker-compose exec backend npx prisma studio
```

#### Database Operations
```bash
# Run migrations
docker-compose exec backend npx prisma migrate deploy

# Reset database
docker-compose exec backend npx prisma migrate reset

# Generate Prisma client
docker-compose exec backend npx prisma generate

# Open Prisma Studio
docker-compose exec backend npx prisma studio
```

#### Debugging
```bash
# Check container status
docker-compose ps

# Check container health
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# View detailed logs
docker-compose logs -f backend

# Access container shell
docker-compose exec backend sh
docker-compose exec postgres psql -U zauro_user -d zauro_db
```

### Service Health Checks

#### Backend Health Check
```bash
curl http://localhost:3000/api/v1/health
```

#### Hedera Service Health Check
```bash
curl http://localhost:3001/collection-status
```

#### Database Health Check
```bash
docker-compose exec postgres pg_isready -U zauro_user -d zauro_db
```

### Performance Optimization

#### Database Performance
- Ensure PostgreSQL has sufficient memory allocation
- Use SSD storage for better I/O performance
- Monitor slow queries with Prisma logging

#### Container Resource Limits
```yaml
# Add to docker-compose.yml services
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
```

### Security Checklist

#### Environment Security
- [ ] Change all default passwords
- [ ] Use strong JWT secrets (32+ characters)
- [ ] Set proper file permissions on `.env`
- [ ] Use HTTPS in production
- [ ] Enable CORS properly

#### Database Security
- [ ] Use strong database passwords
- [ ] Limit database access to application containers
- [ ] Enable SSL for database connections
- [ ] Regular database backups

---

## 📊 Monitoring & Analytics

### Application Monitoring
- **Health Endpoints**: System health and readiness checks
- **Performance Metrics**: Request/response timing and throughput
- **Error Tracking**: Comprehensive error logging and alerting
- **Database Monitoring**: Query performance and connection health

### Business Analytics
- **Trade Volume Tracking**: Transaction volume and value metrics
- **User Activity Monitoring**: Registration, login, and engagement metrics
- **Animal Registration Stats**: Species distribution and registration trends
- **Revenue Analytics**: Trading fees and revenue tracking

---

## 🌟 Unique Features & Innovations

### Blockchain Integration
- **Native NFT Support**: Animals as first-class NFTs on Hedera
- **Atomic Swaps**: Fraud-proof trading with simultaneous asset exchange
- **Immutable Ownership**: Blockchain-verified ownership history
- **Smart Contract Ready**: Architecture prepared for smart contract integration

### AI Integration
- **Market Value Prediction**: AI-powered animal valuation
- **Breed Recognition**: Automated breed identification from images
- **Health Assessment**: AI analysis of veterinary records
- **Market Trend Analysis**: Predictive analytics for trading patterns

### User Experience
- **Comprehensive File Management**: Integrated image and document handling
- **Multi-Channel Notifications**: Email and SMS notification system
- **Real-Time Updates**: Live trade status and balance updates
- **Mobile-First API**: Optimized for mobile application integration

---

## 🔮 Future Roadmap & Extensibility

### Planned Enhancements
- **Smart Contract Integration**: Full atomic swap smart contracts
- **Real-Time Features**: WebSocket support for live updates
- **Advanced Search**: AI-powered search and recommendation engine
- **Mobile App Support**: Dedicated mobile API optimizations
- **Multi-Language Support**: Internationalization and localization

### Scalability Roadmap
- **Microservice Architecture**: Service decomposition for independent scaling
- **Event-Driven Architecture**: Asynchronous processing with message queues
- **Global CDN**: Worldwide content delivery network
- **Multi-Region Deployment**: Geographic distribution for low latency

### Integration Possibilities
- **Third-Party Wallets**: Support for external Hedera wallets
- **Payment Gateways**: Traditional payment method integration
- **Social Features**: User profiles, reviews, and social trading
- **Analytics Platforms**: Advanced business intelligence integration

---

## 🛠️ Technical Configuration

### Required Environment Variables
```bash
# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/zauro_db"

# JWT Security
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
JWT_REFRESH_SECRET="your-super-secret-refresh-jwt-key-change-in-production"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Hedera Blockchain
HEDERA_ACCOUNT_ID="0.0.123456"
HEDERA_PRIVATE_KEY="302e020100300506032b657004220420..."
HEDERA_NETWORK="testnet"

# Supabase Storage
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"

# Communication Services
MAILERSEND_API_KEY="mlsn.your-mailersend-api-key"
MAILERSEND_FROM="noreply@yourdomain.com"
TWILIO_ACCOUNT_SID="your-twilio-account-sid"
TWILIO_AUTH_TOKEN="your-twilio-auth-token"

# Security
ENCRYPTION_KEY="your-32-character-encryption-key"

# Performance
THROTTLE_TTL=60
THROTTLE_LIMIT=10
```

### Deployment Requirements
- **Node.js**: Version 18 or higher
- **PostgreSQL**: Version 13 or higher
- **Memory**: Minimum 512MB RAM, recommended 2GB+
- **Storage**: SSD recommended for database performance
- **Network**: HTTPS/TLS support required for production

---

## 📧 Email Service Migration (MailerSend)

### Migration from Nodemailer to MailerSend

The Zauro Marketplace has been migrated from Nodemailer (SMTP) to MailerSend for improved email deliverability and advanced features.

#### Key Changes:
- **Removed**: `nodemailer` and `@types/nodemailer` packages
- **Added**: `mailersend` package
- **Updated**: Email service configuration and implementation
- **Enhanced**: Email templates with both HTML and plain text versions

#### Required Environment Variables:
```bash
# Replace old SMTP configuration with:
MAILERSEND_API_KEY="mlsn.your-mailersend-api-key-here"
MAILERSEND_FROM="noreply@yourdomain.com"
```

#### Features:
- ✅ Transactional email delivery
- ✅ Password reset OTP emails
- ✅ Welcome emails for new users
- ✅ Trade notification emails
- ✅ HTML and plain text email templates
- ✅ Improved deliverability rates
- ✅ Advanced email analytics (via MailerSend dashboard)

#### Setup Instructions:
1. Create a MailerSend account at [mailersend.com](https://www.mailersend.com/)
2. Add and verify your sending domain in MailerSend dashboard
3. Generate an API key from your MailerSend dashboard
4. Update your environment variables with the new configuration:
   ```bash
   MAILERSEND_API_KEY="your-api-key-here"
   MAILERSEND_FROM="noreply@yourdomain.com"  # Must be verified domain
   ```
5. Restart your application

#### Important Notes:
- **Trial Account**: Can only send emails to the administrator's email address
- **Domain Verification**: The `MAILERSEND_FROM` email domain must be verified in your MailerSend account
- **Production**: Upgrade to a paid plan to send emails to any recipient

---

## 📈 Performance Benchmarks

### Expected Performance Metrics
- **API Response Time**: < 200ms for 95% of requests
- **Database Query Time**: < 50ms for standard queries
- **File Upload Speed**: Up to 10MB files in < 5 seconds
- **Concurrent Users**: Supports 1000+ concurrent users
- **Transaction Throughput**: 100+ trades per minute

### Scalability Targets
- **Horizontal Scaling**: Linear scaling with additional instances
- **Database Performance**: 10,000+ queries per second capability
- **File Storage**: Unlimited with Supabase CDN
- **Blockchain Integration**: Hedera's high throughput (10,000+ TPS)

---

## 🎯 Success Metrics & KPIs

### Technical Metrics
- **System Uptime**: 99.9% availability target
- **API Success Rate**: > 99.5% successful requests
- **Error Rate**: < 0.5% error rate across all endpoints
- **Security Incidents**: Zero security breaches

### Business Metrics
- **User Registration**: Track new user acquisition
- **Animal Listings**: Monitor animal registration volume
- **Trade Volume**: Track successful trade completion
- **Revenue Generation**: Trading fees and transaction volume

---

## 🤝 Integration Ecosystem

### External Service Dependencies
- **Hedera Hashgraph**: Blockchain infrastructure for NFTs and payments
- **Supabase**: File storage and CDN services
- **Twilio**: SMS delivery and phone verification
- **SMTP Services**: Email delivery (Gmail, SendGrid, etc.)
- **PostgreSQL**: Primary database storage

### Third-Party Integration Points
- **Wallet Providers**: Future integration with external Hedera wallets
- **Payment Processors**: Traditional payment method support
- **Analytics Services**: Business intelligence and monitoring
- **Social Platforms**: Social media integration for sharing

---

## 🏆 Competitive Advantages

### Technical Advantages
- **Blockchain-Native**: True decentralized ownership with NFTs
- **Enterprise Security**: Bank-level security with encryption and authentication
- **Scalable Architecture**: Modern microservice-ready design
- **Comprehensive API**: Full-featured REST API with extensive documentation

### Business Advantages
- **Atomic Trading**: Fraud-proof trading with simultaneous asset exchange
- **Multi-Modal Communication**: Email and SMS notification support
- **AI-Enhanced**: Intelligent market valuation and breed recognition
- **Global Reach**: Blockchain-based trading without geographical limitations

---

## 📚 Documentation & Support

### Available Documentation
- **API Documentation**: Complete Swagger/OpenAPI specification
- **Database Schema**: Detailed entity relationship diagrams
- **Deployment Guide**: Step-by-step production deployment
- **Security Guide**: Comprehensive security implementation details

### Developer Resources
- **Code Examples**: Sample implementations for common use cases
- **SDK/Libraries**: Client libraries for popular programming languages
- **Testing Tools**: Comprehensive test suites and mocking utilities
- **Development Environment**: Docker-based development setup

---

## 🔄 Maintenance & Updates

### Regular Maintenance
- **Security Updates**: Monthly security patch reviews and updates
- **Dependency Management**: Regular dependency updates and vulnerability scanning
- **Performance Optimization**: Quarterly performance reviews and optimizations
- **Database Maintenance**: Regular cleanup, indexing, and optimization

### Feature Updates
- **API Versioning**: Backward-compatible API evolution
- **Feature Flags**: Safe feature rollout with toggle capabilities
- **A/B Testing**: Built-in support for feature testing
- **User Feedback Integration**: Continuous improvement based on user feedback

---

**Built with ❤️ for the Zauro Marketplace**

*This comprehensive overview represents a complete blockchain-based animal marketplace solution, combining cutting-edge technology with robust business logic to create a secure, scalable, and user-friendly trading platform.*

---

## 📝 Document Information

- **Version**: 1.0
- **Last Updated**: December 2024
- **Document Type**: Technical Project Overview
- **Audience**: Technical stakeholders, developers, and project managers
- **Status**: Current and Active
