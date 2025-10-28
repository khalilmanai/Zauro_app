# Comprehensive Endpoint Testing Guide

## Prerequisites
1. Backend running on `http://localhost:3000`
2. Test user credentials (create a new user or use existing)
3. Postman, Thunder Client, or curl

## Test Flow

### Phase 1: Authentication ✅

#### 1. Register User
```bash
POST http://localhost:3000/api/v1/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test1234!",
  "firstName": "Test",
  "lastName": "User",
  "phone": "+1234567890"
}

# Expected: 201 Created with accessToken and refreshToken
```

#### 2. Login User
```bash
POST http://localhost:3000/api/v1/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "Test1234!"
}

# Expected: 200 OK with accessToken
# Save the accessToken for subsequent requests
```

#### 3. Get Profile
```bash
GET http://localhost:3000/api/v1/auth/profile
Authorization: Bearer {accessToken}

# Expected: 200 OK with user profile
```

#### 4. Refresh Token
```bash
POST http://localhost:3000/api/v1/auth/refresh
Authorization: Bearer {accessToken}

# Expected: 200 OK with new accessToken
```

#### 5. Forgot Password Flow
```bash
# Request OTP
POST http://localhost:3000/api/v1/auth/forgot-password/request
Content-Type: application/json

{
  "email": "test@example.com"
}

# Verify OTP
POST http://localhost:3000/api/v1/auth/forgot-password/verify
Content-Type: application/json

{
  "email": "test@example.com",
  "code": "123456"
}

# Reset Password
POST http://localhost:3000/api/v1/auth/forgot-password/reset
Content-Type: application/json

{
  "email": "test@example.com",
  "code": "123456",
  "newPassword": "NewTest1234!"
}
```

### Phase 2: Wallet Operations ✅

#### 6. Create Wallet
```bash
POST http://localhost:3000/api/v1/wallets/create
Authorization: Bearer {accessToken}

# Expected: 201 Created with wallet details and Hedera account ID
```

#### 7. Get My Wallet
```bash
GET http://localhost:3000/api/v1/wallets/my-wallet
Authorization: Bearer {accessToken}

# Expected: 200 OK with wallet details
```

#### 8. Get My Wallet Balance
```bash
GET http://localhost:3000/api/v1/wallets/my-wallet/balance
Authorization: Bearer {accessToken}

# Expected: 200 OK with HBAR and ZAU balances
# Example: { "hbar": "100.12345678", "zau": "1000.50" }
```

#### 9. Fund My Account (Test funding)
```bash
POST http://localhost:3000/api/v1/wallets/fund/my-account
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "amount": "50.0",
  "memo": "Test funding"
}

# Expected: 200 OK with transaction hash
```

#### 10. Transfer HBAR
```bash
POST http://localhost:3000/api/v1/wallets/transfer/hbar
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "toAccountId": "0.0.123456",
  "amount": "10.5"
}

# Expected: 200 OK with transaction hash
```

### Phase 3: Animal Management ✅

#### 11. Create Animal (without image)
```bash
POST http://localhost:3000/api/v1/animals
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "Buddy",
  "species": "DOG",
  "breed": "Golden Retriever",
  "age": 3,
  "description": "Friendly and energetic dog",
  "aiPredictionValue": 1500.50
}

# Expected: 201 Created with animal details and NFT token ID
```

#### 12. Create Animal (with image)
```bash
POST http://localhost:3000/api/v1/animals
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

name: Buddy
species: DOG
breed: Golden Retriever
age: 3
description: Friendly and energetic dog
image: [file]

# Expected: 201 Created with animal details and image URL
```

#### 13. Get All Animals
```bash
GET http://localhost:3000/api/v1/animals?page=1&limit=10
Authorization: Bearer {accessToken}

# Expected: 200 OK with paginated animals list
```

#### 14. Get Animal by ID
```bash
GET http://localhost:3000/api/v1/animals/{animalId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with animal details
```

#### 15. Update Animal
```bash
PATCH http://localhost:3000/api/v1/animals/{animalId}
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "Buddy Updated",
  "age": 4
}

# Expected: 200 OK with updated animal
```

#### 16. Upload Animal Image
```bash
POST http://localhost:3000/api/v1/animals/{animalId}/upload-image
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

image: [file]

# Expected: 200 OK with updated animal
```

#### 17. Upload Vet Record
```bash
POST http://localhost:3000/api/v1/animals/{animalId}/upload-vet-record
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

vetRecord: [file]

# Expected: 200 OK with updated animal
```

### Phase 4: Trading ✅

#### 18. List Animal for Trade
```bash
POST http://localhost:3000/api/v1/trades/list
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "animalId": "{animalId}",
  "price": 1500.50,
  "currency": "HBAR"
}

# Expected: 201 Created with trade listing
```

#### 19. Get All Trades
```bash
GET http://localhost:3000/api/v1/trades?page=1&limit=10
Authorization: Bearer {accessToken}

# Expected: 200 OK with paginated trades
```

#### 20. Get Trade by ID
```bash
GET http://localhost:3000/api/v1/trades/{tradeId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with trade details
```

#### 21. Buy Animal (Initiate Trade)
```bash
POST http://localhost:3000/api/v1/trades/buy/{tradeId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with updated trade (PENDING status)
```

#### 22. Execute Trade
```bash
POST http://localhost:3000/api/v1/trades/execute/{tradeId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with completed trade
```

#### 23. Cancel Trade
```bash
POST http://localhost:3000/api/v1/trades/cancel/{tradeId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with cancelled trade
```

### Phase 5: DID & Credentials ✅

#### 24. Create DID
```bash
POST http://localhost:3000/api/v1/did/create
Authorization: Bearer {accessToken}

# Expected: 201 Created with DID
```

#### 25. Get My DID
```bash
GET http://localhost:3000/api/v1/did/my-did
Authorization: Bearer {accessToken}

# Expected: 200 OK with DID and document
```

#### 26. Resolve DID
```bash
GET http://localhost:3000/api/v1/did/resolve/{did}

# Expected: 200 OK with DID document
```

#### 27. Get My Credentials
```bash
GET http://localhost:3000/api/v1/did/credentials
Authorization: Bearer {accessToken}

# Expected: 200 OK with credentials array
```

#### 28. Issue KYC Credential
```bash
POST http://localhost:3000/api/v1/did/credentials/issue/kyc
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "level": "basic",
  "provider": "KYCProvider",
  "country": "US"
}

# Expected: 201 Created with KYC credential
```

#### 29. Issue Reputation Credential
```bash
POST http://localhost:3000/api/v1/did/credentials/issue/reputation
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "score": 95,
  "totalTrades": 10,
  "successfulTrades": 9,
  "averageRating": 4.8
}

# Expected: 201 Created with reputation credential
```

#### 30. Issue Veterinary Credential
```bash
POST http://localhost:3000/api/v1/did/credentials/issue/veterinary
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "vetId": "vet_123",
  "vetName": "Dr. Smith",
  "examinationDate": "2024-01-01",
  "healthStatus": "healthy",
  "vaccinations": ["rabies", "distemper"],
  "animalId": "{animalId}"
}

# Expected: 201 Created with veterinary credential
```

#### 31. Verify Credential
```bash
POST http://localhost:3000/api/v1/did/credentials/verify
Content-Type: application/json

{
  "credential": { /* credential object */ }
}

# Expected: 200 OK with validity status
```

#### 32. Revoke Credential
```bash
POST http://localhost:3000/api/v1/did/credentials/revoke/{credentialId}
Authorization: Bearer {accessToken}

# Expected: 200 OK with revocation confirmation
```

### Phase 6: Admin/Collections (Requires Admin Role) ✅

#### 33. Create NFT Collection
```bash
POST http://localhost:3000/api/v1/admin/collections
Authorization: Bearer {adminAccessToken}
Content-Type: application/json

{
  "name": "Animals",
  "symbol": "ANML",
  "memo": "Primary marketplace collection",
  "maxSupply": 10000,
  "isDefault": true
}

# Expected: 201 Created with collection details
```

#### 34. List All Collections
```bash
GET http://localhost:3000/api/v1/admin/collections
Authorization: Bearer {adminAccessToken}

# Expected: 200 OK with collections array
```

#### 35. Get Default Collection
```bash
GET http://localhost:3000/api/v1/admin/collections/default

# Expected: 200 OK with default collection
```

## Automated Test Results

### Success Criteria
- ✅ All authentication endpoints working
- ✅ Wallet creation and balance retrieval functional
- ✅ Animal CRUD operations with NFT minting
- ✅ Trading flow (list, buy, execute, cancel)
- ✅ DID and credential management
- ✅ Admin collection management

### Expected Behavior in App
1. **Login Flow:**
   - User logs in → Wallet auto-created → Balance auto-loaded → Displayed on dashboard

2. **Dashboard:**
   - Shows HBAR balance from wallet
   - Shows ZAU balance from wallet
   - Auto-refreshes on pull-to-refresh

3. **Wallet Screen:**
   - Displays current balances
   - Transfer functionality
   - Transaction history

## Common Issues & Solutions

### Issue: Wallet Not Auto-Creating
**Solution:** Check that `app_lifecycle_provider.dart` is initialized in `main.dart`

### Issue: Balance Shows 0.00
**Solution:** 
1. Ensure wallet is created
2. Fund the account using `/wallets/fund/my-account`
3. Refresh the balance

### Issue: NFT Minting Fails
**Solution:** 
1. Ensure default collection exists
2. Check Hedera testnet connection
3. Verify wallet has enough HBAR for transaction fees

### Issue: Trades Not Appearing
**Solution:**
1. Ensure animal is listed (`POST /trades/list`)
2. Check trade status filter
3. Verify authentication token

## Testing Checklist

- [ ] User can register and login
- [ ] Wallet is automatically created on login
- [ ] Balance is displayed on dashboard
- [ ] User can create animals with NFTs
- [ ] User can list animals for trade
- [ ] User can view marketplace
- [ ] User can buy and execute trades
- [ ] User can transfer HBAR
- [ ] DID is created for user
- [ ] Credentials can be issued and verified
- [ ] Admin can manage collections

## Notes
- All timestamps are in ISO 8601 format
- All HBAR amounts are in decimal string format
- All Hedera account IDs follow format `0.0.123456`
- Images are uploaded to Supabase storage
- JWT tokens expire after 24 hours (refresh as needed)

