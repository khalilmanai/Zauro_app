# Backend Endpoints for Frontend Integration

This document provides a comprehensive reference for all backend API endpoints in the Zauro Marketplace application.

## 📖 Quick Reference

- **Base URL**: `http://localhost:3000/api/v1` (Development)
- **API Documentation**: `http://localhost:3000/docs` (Swagger UI)
- **Total Endpoints**: 49 endpoints across 7 main modules
- **Authentication**: JWT Bearer tokens (most endpoints)

## 📋 Endpoint Summary

| Module | Endpoints Count | Authentication Required |
|--------|----------------|------------------------|
| Authentication | 7 | Partial |
| Wallet | 9 | Yes |
| Animals | 10 | Partial |
| Trades | 6 | Partial |
| Collections | 6 | Yes (Admin/Manager) |
| DID | 10 | Yes |
| App | 1 | No |

## 📚 Table of Contents

1. [Authentication Endpoints](#-authentication-endpoints-auth) - User registration, login, password reset
2. [Wallet Endpoints](#-wallet-endpoints-wallets) - Hedera wallet management, HBAR transfers
3. [Animal Endpoints](#-animal-endpoints-animals) - Animal NFT creation, review, and management
4. [Trading Endpoints](#-trading-endpoints-trades) - List, buy, and trade animal NFTs
5. [Collections Endpoints](#️-collections-endpoints-admincollections) - Admin NFT collection management
6. [DID Endpoints](#-did-endpoints-did) - Decentralized identity and credentials
7. [App Endpoints](#-app-endpoints) - Health check and status
8. [Common Workflows](#-common-workflows) - Examples of typical use cases

## Authentication
Most endpoints require JWT Bearer token authentication. Add the header:
```
Authorization: Bearer <your_jwt_token>
```

---

## 🔐 Authentication Endpoints (`/auth`)

### 1. Register User
**Endpoint**: `POST /api/v1/auth/register`  
**Authentication**: Not required  
**Request Body**:
```json
{
  "email": "john.doe@example.com",
  "phone": "+1234567890", // Optional
  "password": "SecurePassword123!", // Min 8 characters
  "firstName": "John",
  "lastName": "Doe"
}
```
**Response** (201 Created):
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "cm4abc123def456ghi789jkl",
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER",
    "isVerified": false
  }
}
```

### 2. Login User
**Endpoint**: `POST /api/v1/auth/login`  
**Authentication**: Not required  
**Request Body**:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```
**Response** (200 OK): Same as register response

### 3. Refresh Token
**Endpoint**: `POST /api/v1/auth/refresh`  
**Authentication**: Required (JWT)  
**Request Body**: None  
**Response** (200 OK):
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### 4. Request Password Reset OTP
**Endpoint**: `POST /api/v1/auth/forgot-password/request`  
**Authentication**: Not required  
**Request Body**:
```json
{
  "email": "john.doe@example.com" // OR "phone": "+1234567890"
}
```
**Response** (200 OK):
```json
{
  "message": "OTP sent successfully"
}
```

### 5. Verify Password Reset OTP
**Endpoint**: `POST /api/v1/auth/forgot-password/verify`  
**Authentication**: Not required  
**Request Body**:
```json
{
  "code": "123456",
  "email": "john.doe@example.com" // OR "phone": "+1234567890"
}
```
**Response** (200 OK):
```json
{
  "message": "OTP verified successfully"
}
```

### 6. Reset Password
**Endpoint**: `POST /api/v1/auth/forgot-password/reset`  
**Authentication**: Not required  
**Request Body**:
```json
{
  "code": "123456",
  "newPassword": "NewSecurePassword123!",
  "email": "john.doe@example.com" // OR "phone": "+1234567890"
}
```
**Response** (200 OK):
```json
{
  "message": "Password reset successfully"
}
```

### 7. Get User Profile
**Endpoint**: `GET /api/v1/auth/profile`  
**Authentication**: Required (JWT)  
**Response** (200 OK):
```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "cm4abc123def456ghi789jkl",
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "USER",
    "isVerified": true
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## 💰 Wallet Endpoints (`/wallets`)

All wallet endpoints require JWT authentication.

### 8. Create Wallet
**Endpoint**: `POST /api/v1/wallets/create`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "userId": "cm4abc123def456ghi789jkl" // Optional - ignored, uses authenticated user
}
```
**Response** (201 Created):
```json
{
  "id": "cm4abc123def456ghi789jkl",
  "hederaAccountId": "0.0.123456",
  "publicKey": "302a300506032b65700321004f2b8c8d...",
  "balance": {
    "hbar": "100.12345678",
    "zau": "1000.50"
  },
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 9. Get My Wallet
**Endpoint**: `GET /api/v1/wallets/my-wallet`  
**Authentication**: Required (JWT)  
**Response** (200 OK): Same as create wallet response

### 10. Get My Wallet Balance
**Endpoint**: `GET /api/v1/wallets/my-wallet/balance`  
**Authentication**: Required (JWT)  
**Response** (200 OK):
```json
{
  "hbar": "100.12345678",
  "zau": "1000.50"
}
```

### 11. Transfer HBAR
**Endpoint**: `POST /api/v1/wallets/transfer/hbar`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "toAccountId": "0.0.654321", // Hedera account ID format
  "amount": "10.5" // HBAR amount (positive number)
}
```
**Response** (200 OK):
```json
{
  "transactionHash": "0.0.123456@1695804600.123456789"
}
```

### 12. Fund My Account
**Endpoint**: `POST /api/v1/wallets/fund/my-account`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "amount": "50.0", // HBAR amount to fund
  "accountId": "0.0.654321", // Optional - target account ID
  "memo": "Initial funding for new user account" // Optional memo
}
```
**Response** (200 OK): Same as transfer HBAR response

### 13. Fund Any Account
**Endpoint**: `POST /api/v1/wallets/fund/account`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "amount": "25.0", // HBAR amount to fund
  "accountId": "0.0.654321", // Required - target Hedera account ID
  "memo": "Funding external account" // Optional memo
}
```
**Response** (200 OK): Same as transfer HBAR response

### 14. Create Wallet with Balance
**Endpoint**: `POST /api/v1/wallets/create-with-balance`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "amount": "100.0" // Initial HBAR balance for new wallet
}
```
**Response** (201 Created): Same as create wallet response

### 15. Get Wallet by ID
**Endpoint**: `GET /api/v1/wallets/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Wallet ID or User ID  
**Response** (200 OK): Same as create wallet response

### 16. Get Wallet Balance by ID
**Endpoint**: `GET /api/v1/wallets/{id}/balance`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Wallet ID or User ID  
**Response** (200 OK): Same as get balance response

---

## 🐕 Animal Endpoints (`/animals`)

### 17. Create Animal (Pending Expert Review)
**Endpoint**: `POST /api/v1/animals`  
**Authentication**: Required (JWT)  
**Content-Type**: `multipart/form-data`  
**Description**: Creates a new animal entry that requires expert review before NFT minting  
**Request Body** (Form Data):
```
name: string // Required
species: string // Required (DOG, CAT, BIRD, FISH, etc.)
breed: string // Optional
age: number // Optional (0-50)
description: string // Optional
aiPredictionValue: number // Optional
image: File // Optional - image file
```
**Response** (201 Created):
```json
{
  "id": "animal_123",
  "name": "Buddy",
  "species": "DOG",
  "breed": "Golden Retriever",
  "age": 3,
  "description": "Friendly and energetic dog...",
  "tokenId": null,
  "tokenSerialNumber": null,
  "imageUrl": "https://supabase-url/image.jpg",
  "vetRecordUrl": null,
  "aiPredictionValue": "1500.50",
  "ownerId": "cm4abc123def456ghi789jkl",
  "isListed": false,
  "reviewStatus": "PENDING",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  "owner": {
    "id": "cm4abc123def456ghi789jkl",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com"
  }
}
```

### 18. Get All Animals
**Endpoint**: `GET /api/v1/animals`  
**Authentication**: Not required  
**Query Parameters**:
- `page` (number, optional): Page number (default: 1)
- `limit` (number, optional): Items per page (default: 10)
- `ownerId` (string, optional): Filter by owner ID  
**Response** (200 OK):
```json
{
  "success": true,
  "message": "Animals retrieved successfully",
  "data": [
    // Array of animal objects, same structure as create animal response
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 50,
    "totalPages": 5
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 19. Get Animals Pending Review
**Endpoint**: `GET /api/v1/animals/pending-review`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Query Parameters**:
- `page` (number, optional): Page number (default: 1)
- `limit` (number, optional): Items per page (default: 10)  
**Response** (200 OK):
```json
{
  "success": true,
  "message": "Pending review animals retrieved successfully",
  "data": [
    // Array of animal objects awaiting review
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 15,
    "totalPages": 2
  }
}
```

### 20. Review Animal (Approve/Reject)
**Endpoint**: `PUT /api/v1/animals/{id}/review`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Path Parameters**:
- `id` (string): Animal ID  
**Request Body**:
```json
{
  "approved": true, // true to approve, false to reject
  "comment": "Animal verified and meets quality standards" // Optional review comment
}
```
**Response** (200 OK): Same as create animal response

### 21. Mint Animal NFT
**Endpoint**: `POST /api/v1/animals/{id}/mint`  
**Authentication**: Required (JWT)  
**Description**: Mints NFT after expert approval  
**Path Parameters**:
- `id` (string): Animal ID  
**Response** (201 Created): Same as create animal response (with tokenId and tokenSerialNumber populated)

### 22. Get Animal by ID
**Endpoint**: `GET /api/v1/animals/{id}`  
**Authentication**: Not required  
**Path Parameters**:
- `id` (string): Animal ID  
**Response** (200 OK): Same as create animal response

### 23. Update Animal
**Endpoint**: `PATCH /api/v1/animals/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Animal ID  
**Request Body** (Partial UpdateAnimalDto):
```json
{
  "name": "Buddy Updated",
  "description": "Updated description",
  "age": 4
}
```
**Response** (200 OK): Same as create animal response

### 24. Delete Animal (Burn NFT)
**Endpoint**: `DELETE /api/v1/animals/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Animal ID  
**Response** (200 OK):
```json
{
  "message": "Animal deleted and NFT burned successfully"
}
```

### 25. Upload Animal Image
**Endpoint**: `POST /api/v1/animals/{id}/upload-image`  
**Authentication**: Required (JWT)  
**Content-Type**: `multipart/form-data`  
**Path Parameters**:
- `id` (string): Animal ID  
**Request Body** (Form Data):
```
image: File // Required - image file
```
**Response** (200 OK): Same as create animal response

### 26. Upload Vet Record
**Endpoint**: `POST /api/v1/animals/{id}/upload-vet-record`  
**Authentication**: Required (JWT)  
**Content-Type**: `multipart/form-data`  
**Path Parameters**:
- `id` (string): Animal ID  
**Request Body** (Form Data):
```
vetRecord: File // Required - vet record file
```
**Response** (200 OK): Same as create animal response

---

## 💱 Trading Endpoints (`/trades`)

### 27. List Animal for Trade
**Endpoint**: `POST /api/v1/trades/list`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "animalId": "animal_123", // Required - ID of animal to list
  "price": 1500.50, // Required - listing price
  "currency": "HBAR" // Optional - default: HBAR
}
```
**Response** (201 Created):
```json
{
  "id": "trade_456",
  "animalId": "animal_123",
  "sellerId": "cm4abc123def456ghi789jkl",
  "buyerId": null,
  "price": "1500.50",
  "currency": "HBAR",
  "status": "LISTED",
  "contractAddress": null,
  "transactionHash": null,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  "completedAt": null,
  "animal": {
    "id": "animal_123",
    "name": "Buddy",
    "species": "DOG",
    "imageUrl": "https://supabase-url/image.jpg",
    "owner": {
      "id": "seller_id",
      "firstName": "John",
      "lastName": "Doe"
    }
  },
  "seller": {
    "id": "cm4abc123def456ghi789jkl",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com"
  },
  "buyer": null
}
```

### 28. Get All Trades
**Endpoint**: `GET /api/v1/trades`  
**Authentication**: Not required  
**Query Parameters**:
- `page` (number, optional): Page number (default: 1)
- `limit` (number, optional): Items per page (default: 10)
- `status` (string, optional): Filter by trade status (LISTED, PENDING, COMPLETED, CANCELLED)  
**Response** (200 OK):
```json
{
  "success": true,
  "message": "Trades retrieved successfully",
  "data": [
    // Array of trade objects, same structure as list trade response
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "totalPages": 3
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### 29. Get Trade by ID
**Endpoint**: `GET /api/v1/trades/{id}`  
**Authentication**: Not required  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response

### 30. Buy Animal (Initiate Trade)
**Endpoint**: `POST /api/v1/trades/buy/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with updated status)

### 31. Execute Trade (Complete Atomic Swap)
**Endpoint**: `POST /api/v1/trades/execute/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with COMPLETED status)

### 32. Cancel Trade
**Endpoint**: `POST /api/v1/trades/cancel/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with CANCELLED status)

---

## 🏛️ Collections Endpoints (`/admin/collections`)

Admin-only endpoints for managing NFT collections.

### 33. Create NFT Collection
**Endpoint**: `POST /api/v1/admin/collections`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Request Body**:
```json
{
  "name": "Animals",
  "symbol": "ANML",
  "memo": "Primary marketplace collection", // Optional
  "maxSupply": 10000, // Optional
  "isDefault": true // Optional
}
```
**Response** (201 Created): Collection details

### 34. List All Collections
**Endpoint**: `GET /api/v1/admin/collections`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Response** (200 OK): Array of collections

### 35. Get Default Collection
**Endpoint**: `GET /api/v1/admin/collections/default`  
**Authentication**: Not required  
**Response** (200 OK): Default collection details

### 36. Rotate Default Collection if Full
**Endpoint**: `POST /api/v1/admin/collections/rotate-if-full`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Request Body**:
```json
{
  "namePrefix": "NewCollection", // Optional
  "symbolPrefix": "NC", // Optional
  "memo": "Rotated collection" // Optional
}
```
**Response** (200 OK): New or existing default collection

### 37. Disable Collection
**Endpoint**: `PATCH /api/v1/admin/collections/{id}/disable`  
**Authentication**: Required (JWT) - Role: ADMIN  
**Path Parameters**:
- `id` (string): Collection ID  
**Response** (200 OK): Updated collection

### 38. Set Collection as Default
**Endpoint**: `PATCH /api/v1/admin/collections/{id}/default`  
**Authentication**: Required (JWT) - Role: ADMIN  
**Path Parameters**:
- `id` (string): Collection ID  
**Response** (200 OK): Updated collection

---

## 🆔 DID Endpoints (`/did`)

Endpoints for Decentralized Identifiers (DID) and credentials.

### 39. Get My DID
**Endpoint**: `GET /api/v1/did/my-did`  
**Authentication**: Required (JWT)  
**Response** (200 OK):
```json
{
  "did": "did:hedera:testnet:0.0.123456_0.0.789",
  "document": { /* DID document */ },
  "message": "DID retrieved successfully"
}
```

### 40. Create DID
**Endpoint**: `POST /api/v1/did/create`  
**Authentication**: Required (JWT)  
**Response** (201 Created):
```json
{
  "did": "did:hedera:testnet:0.0.123456_0.0.789",
  "document": { /* DID document */ },
  "message": "DID created successfully"
}
```

### 41. Resolve DID
**Endpoint**: `GET /api/v1/did/resolve/{did}`  
**Authentication**: Required (JWT)  
**Note**: This endpoint currently requires JWT authentication due to controller-level guard  
**Path Parameters**:
- `did` (string): DID to resolve  
**Response** (200 OK):
```json
{
  "did": "did:hedera:testnet:0.0.123456_0.0.789",
  "document": { /* DID document */ },
  "message": "DID resolved successfully"
}
```

### 42. Get My Credentials
**Endpoint**: `GET /api/v1/did/credentials`  
**Authentication**: Required (JWT)  
**Response** (200 OK):
```json
{
  "credentials": [ /* Array of credentials */ ],
  "count": 5,
  "message": "Credentials retrieved successfully"
}
```

### 43. Get Credentials by Type
**Endpoint**: `GET /api/v1/did/credentials/{type}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `type` (string): Credential type (e.g., KYC, REPUTATION, VETERINARY)  
**Response** (200 OK): Same as above

### 44. Issue KYC Credential
**Endpoint**: `POST /api/v1/did/credentials/issue/kyc`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "level": "basic", // basic | enhanced | premium
  "provider": "KYCProvider",
  "country": "US", // Optional
  "documentType": "passport" // Optional
}
```
**Response** (201 Created):
```json
{
  "credential": { /* Credential object */ },
  "message": "KYC credential issued successfully"
}
```

### 45. Issue Reputation Credential
**Endpoint**: `POST /api/v1/did/credentials/issue/reputation`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "score": 95,
  "totalTrades": 10,
  "successfulTrades": 9,
  "averageRating": 4.8
}
```
**Response** (201 Created):
```json
{
  "credential": { /* Credential object */ },
  "message": "Reputation credential issued successfully"
}
```

### 46. Issue Veterinary Credential
**Endpoint**: `POST /api/v1/did/credentials/issue/veterinary`  
**Authentication**: Required (JWT)  
**Request Body**:
```json
{
  "vetId": "vet_123",
  "vetName": "Dr. Smith",
  "examinationDate": "2024-01-01",
  "healthStatus": "healthy", // healthy | sick | recovering
  "vaccinations": ["rabies", "distemper"],
  "notes": "All good",
  "animalId": "animal_123"
}
```
**Response** (201 Created):
```json
{
  "credential": { /* Credential object */ },
  "message": "Veterinary credential issued successfully"
}
```

### 47. Verify Credential
**Endpoint**: `POST /api/v1/did/credentials/verify`  
**Authentication**: Required (JWT)  
**Note**: This endpoint currently requires JWT authentication due to controller-level guard  
**Request Body**:
```json
{
  "credential": { /* Credential to verify */ }
}
```
**Response** (200 OK):
```json
{
  "valid": true,
  "message": "Credential is valid"
}
```

### 48. Revoke Credential
**Endpoint**: `POST /api/v1/did/credentials/revoke/{credentialId}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `credentialId` (string): Credential ID  
**Response** (200 OK):
```json
{
  "message": "Credential revoked successfully",
  "credentialId": "cred_123"
}
```

---

## 🏠 App Endpoints

### 49. Health Check
**Endpoint**: `GET /api/v1/`  
**Authentication**: Not required  
**Response** (200 OK):
```
Hello World!
```

---

## 📝 Data Types and Enums

### AnimalSpecies Enum:
- `DOG`, `CAT`, `BIRD`, `FISH`, `REPTILE`, `EXOTIC`, `OTHER`

### AnimalStatus Enum:
- `PENDING_EXPERT_REVIEW` - Animal awaiting expert review
- `EXPERT_APPROVED` - Animal approved by expert, ready for minting
- `EXPERT_REJECTED` - Animal rejected by expert
- `LISTED` - Animal listed for trade
- `MINTED` - Animal NFT has been minted

### TradeStatus Enum:
- `PENDING` - Trade initiated, awaiting execution
- `LISTED` - Animal listed for trade
- `IN_PROGRESS` - Trade in progress
- `COMPLETED` - Trade completed successfully
- `CANCELLED` - Trade cancelled

### UserRole Enum:
- `USER` - Regular user
- `ADMIN` - Administrator with full access
- `HR_MANAGER` - Manager with collection management access

### CredentialStatus Enum:
- `ACTIVE` - Credential is active and valid
- `REVOKED` - Credential has been revoked
- `EXPIRED` - Credential has expired
- `PENDING` - Credential pending verification

### CollectionStatus Enum:
- `ACTIVE` - Collection is active and can be used
- `DISABLED` - Collection is disabled

### Credential Types:
- `KYC` - Know Your Customer credential
- `REPUTATION` - User reputation credential
- `VETERINARY` - Animal veterinary record credential

---

## ⚠️ Important Notes

1. **API Documentation**: Full Swagger/OpenAPI documentation is available at `http://localhost:3000/docs` (or your configured base URL + `/docs`)
2. **Authentication**: Most endpoints require JWT Bearer token authentication. Include in headers: `Authorization: Bearer <your_jwt_token>`
3. **File Uploads**: Use `multipart/form-data` for file uploads (images, vet records).
4. **Hedera Account ID Format**: Must follow pattern `0.0.123456`.
5. **HBAR Amount Format**: Use decimal strings (e.g., "10.5").
6. **Error Responses**: All endpoints return standard HTTP status codes with appropriate error messages.
7. **CORS**: Backend is configured for `http://localhost:3000` origin.
8. **File Storage**: Uses Supabase for file storage.
9. **Blockchain**: Integrates with Hedera network for NFT and wallet functionality.
10. **Roles**: Admin endpoints require specific roles (ADMIN, HR_MANAGER).
11. **Animal Review Workflow**: 
    - Animals are created with status `PENDING` (no NFT minted yet)
    - Admin/Manager reviews and approves/rejects animals
    - After approval, user can mint the NFT via the mint endpoint
    - Only minted animals have `tokenId` and `tokenSerialNumber` populated

---

## 🔄 Common Workflows

### Workflow 1: User Registration and Wallet Creation
```
1. POST /api/v1/auth/register
   → Get accessToken and refreshToken
2. POST /api/v1/wallets/create (with JWT)
   → User wallet created with Hedera account
3. GET /api/v1/wallets/my-wallet (with JWT)
   → Verify wallet creation and get balance
```

### Workflow 2: Create and Mint an Animal NFT
```
1. POST /api/v1/animals (with JWT + image file)
   → Animal created with status PENDING
   → Response: animal with tokenId=null, reviewStatus=PENDING
2. GET /api/v1/animals/pending-review (Admin/Manager JWT)
   → Admin sees pending animals
3. PUT /api/v1/animals/{id}/review (Admin/Manager JWT)
   → Body: { "approved": true, "comment": "Looks good" }
   → Animal approved for minting
4. POST /api/v1/animals/{id}/mint (User JWT)
   → NFT minted on Hedera
   → Response: animal with tokenId and tokenSerialNumber populated
```

### Workflow 3: List and Trade an Animal
```
1. POST /api/v1/trades/list (Seller JWT)
   → Body: { "animalId": "...", "price": 1500.50 }
   → Animal listed for trade
2. GET /api/v1/trades
   → Buyers browse available trades
3. POST /api/v1/trades/buy/{id} (Buyer JWT)
   → Trade initiated, status: PENDING
4. POST /api/v1/trades/execute/{id} (Buyer JWT)
   → Atomic swap executed on Hedera
   → NFT transferred to buyer, HBAR to seller
   → Trade status: COMPLETED
```

### Workflow 4: Password Reset Flow
```
1. POST /api/v1/auth/forgot-password/request
   → Body: { "email": "user@example.com" }
   → OTP sent to email
2. POST /api/v1/auth/forgot-password/verify
   → Body: { "code": "123456", "email": "user@example.com" }
   → OTP verified
3. POST /api/v1/auth/forgot-password/reset
   → Body: { "code": "123456", "newPassword": "NewPass123!", "email": "..." }
   → Password reset successfully
```

### Workflow 5: DID and Credentials
```
1. POST /api/v1/did/create (with JWT)
   → DID created for user
2. POST /api/v1/did/credentials/issue/kyc (with JWT)
   → Body: { "level": "basic", "provider": "KYCProvider" }
   → KYC credential issued
3. GET /api/v1/did/credentials (with JWT)
   → Retrieve all user credentials
4. POST /api/v1/did/credentials/verify (with JWT)
   → Body: { "credential": {...} }
   → Verify credential validity
```

---

## 📞 Common Error Responses

**401 Unauthorized**:
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```

**404 Not Found**:
```json
{
  "statusCode": 404,
  "message": "Resource not found"
}
```

**400 Bad Request**:
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": ["Detailed validation error messages"]
}
```

**409 Conflict**:
```json
{
  "statusCode": 409,
  "message": "Resource already exists"
}
```

**500 Internal Server Error**:
```json
{
  "statusCode": 500,
  "message": "Internal server error"
}
```

---

## 🧪 Testing and Development

### Using Swagger UI
The easiest way to test endpoints is through the Swagger UI:
1. Navigate to `http://localhost:3000/docs`
2. Click "Authorize" button at the top
3. Enter your JWT token in format: `Bearer your_token_here`
4. Click "Authorize" and then "Close"
5. Now you can test any endpoint directly from the browser

### Using Postman/Thunder Client
Import the collection and test endpoints:
1. Set base URL: `http://localhost:3000/api/v1`
2. For authenticated endpoints, add header:
   - Key: `Authorization`
   - Value: `Bearer your_jwt_token`
3. For file uploads, use `form-data` body type

### Getting a Test JWT Token
```bash
# 1. Register a user
POST http://localhost:3000/api/v1/auth/register
Body: {
  "email": "test@example.com",
  "password": "Test1234!",
  "firstName": "Test",
  "lastName": "User"
}

# 2. Copy the accessToken from response
# 3. Use it in Authorization header: Bearer <accessToken>
```

### Environment Variables Required
```env
DATABASE_URL="postgresql://..."
JWT_SECRET="your-secret-key"
JWT_REFRESH_SECRET="your-refresh-secret"
HEDERA_ACCOUNT_ID="0.0.xxxxx"
HEDERA_PRIVATE_KEY="..."
SUPABASE_URL="..."
SUPABASE_SERVICE_KEY="..."
```

---

## 📝 Changelog

### Latest Updates
- Added animal review workflow (PENDING → EXPERT_APPROVED → MINTED)
- Added endpoints for pending review animals
- Added mint endpoint for approved animals
- Updated all endpoint documentation with actual implementation details
- Added comprehensive workflow examples
- Added detailed enum definitions

---

## 📧 Support

For issues or questions:
- Check Swagger documentation: `http://localhost:3000/docs`
- Review this documentation for endpoint details
- Check error responses for debugging information