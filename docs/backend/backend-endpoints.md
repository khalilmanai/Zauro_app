# Backend Endpoints for Frontend Integration

## Base URL
- **Development**: `http://localhost:3000/api/v1`
- **Production**: `https://api.zauro.com/api/v1`

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

### 17. Create Animal with NFT
**Endpoint**: `POST /api/v1/animals`  
**Authentication**: Required (JWT)  
**Content-Type**: `multipart/form-data`  
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
  "tokenId": "0.0.999",
  "tokenSerialNumber": "1",
  "imageUrl": "https://supabase-url/image.jpg",
  "vetRecordUrl": null,
  "aiPredictionValue": "1500.50",
  "ownerId": "cm4abc123def456ghi789jkl",
  "isListed": false,
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

### 19. Get Animal by ID
**Endpoint**: `GET /api/v1/animals/{id}`  
**Authentication**: Not required  
**Path Parameters**:
- `id` (string): Animal ID  
**Response** (200 OK): Same as create animal response

### 20. Update Animal
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

### 21. Delete Animal (Burn NFT)
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

### 22. Upload Animal Image
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

### 23. Upload Vet Record
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

### 24. List Animal for Trade
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

### 25. Get All Trades
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

### 26. Get Trade by ID
**Endpoint**: `GET /api/v1/trades/{id}`  
**Authentication**: Not required  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response

### 27. Buy Animal (Initiate Trade)
**Endpoint**: `POST /api/v1/trades/buy/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with updated status)

### 28. Execute Trade (Complete Atomic Swap)
**Endpoint**: `POST /api/v1/trades/execute/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with COMPLETED status)

### 29. Cancel Trade
**Endpoint**: `POST /api/v1/trades/cancel/{id}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `id` (string): Trade ID  
**Response** (200 OK): Same as list trade response (with CANCELLED status)

---

## 🏛️ Collections Endpoints (`/admin/collections`)

Admin-only endpoints for managing NFT collections.

### 30. Create NFT Collection
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

### 31. List All Collections
**Endpoint**: `GET /api/v1/admin/collections`  
**Authentication**: Required (JWT) - Roles: ADMIN, HR_MANAGER  
**Response** (200 OK): Array of collections

### 32. Get Default Collection
**Endpoint**: `GET /api/v1/admin/collections/default`  
**Authentication**: Not required  
**Response** (200 OK): Default collection details

### 33. Rotate Default Collection if Full
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

### 34. Disable Collection
**Endpoint**: `PATCH /api/v1/admin/collections/{id}/disable`  
**Authentication**: Required (JWT) - Role: ADMIN  
**Path Parameters**:
- `id` (string): Collection ID  
**Response** (200 OK): Updated collection

### 35. Set Collection as Default
**Endpoint**: `PATCH /api/v1/admin/collections/{id}/default`  
**Authentication**: Required (JWT) - Role: ADMIN  
**Path Parameters**:
- `id` (string): Collection ID  
**Response** (200 OK): Updated collection

---

## 🆔 DID Endpoints (`/did`)

Endpoints for Decentralized Identifiers (DID) and credentials.

### 36. Get My DID
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

### 37. Create DID
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

### 38. Resolve DID
**Endpoint**: `GET /api/v1/did/resolve/{did}`  
**Authentication**: Not required  
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

### 39. Get My Credentials
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

### 40. Get Credentials by Type
**Endpoint**: `GET /api/v1/did/credentials/{type}`  
**Authentication**: Required (JWT)  
**Path Parameters**:
- `type` (string): Credential type (e.g., KYC, REPUTATION, VETERINARY)  
**Response** (200 OK): Same as above

### 41. Issue KYC Credential
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

### 42. Issue Reputation Credential
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

### 43. Issue Veterinary Credential
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

### 44. Verify Credential
**Endpoint**: `POST /api/v1/did/credentials/verify`  
**Authentication**: Not required  
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

### 45. Revoke Credential
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

### 46. Health Check
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

### TradeStatus Enum:
- `LISTED`, `PENDING`, `COMPLETED`, `CANCELLED`

### UserRole Enum:
- `USER`, `ADMIN`, `HR_MANAGER`

### Credential Types:
- `KYC`, `REPUTATION`, `VETERINARY`

---

## ⚠️ Important Notes

1. **Authentication**: Most endpoints require JWT Bearer token authentication.
2. **File Uploads**: Use `multipart/form-data` for file uploads (images, vet records).
3. **Hedera Account ID Format**: Must follow pattern `0.0.123456`.
4. **HBAR Amount Format**: Use decimal strings (e.g., "10.5").
5. **Error Responses**: All endpoints return standard HTTP status codes with appropriate error messages.
6. **CORS**: Backend is configured for `http://localhost:3000` origin.
7. **File Storage**: Uses Supabase for file storage.
8. **Blockchain**: Integrates with Hedera network for NFT and wallet functionality.
9. **Roles**: Admin endpoints require specific roles (ADMIN, HR_MANAGER).

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