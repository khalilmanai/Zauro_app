# API Integration Guide

This document provides a comprehensive overview of how all backend endpoints from `backend-endpoints.md` are integrated into the Flutter application.

## 📋 Table of Contents

1. [Authentication Endpoints](#authentication-endpoints)
2. [Wallet Endpoints](#wallet-endpoints)
3. [Animal Endpoints](#animal-endpoints)
4. [Trading Endpoints](#trading-endpoints)
5. [DID Endpoints](#did-endpoints)
6. [Admin Collection Endpoints](#admin-collection-endpoints)
7. [Usage Examples](#usage-examples)

---

## 🔐 Authentication Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/auth/data/models/auth_models.dart`
- **Repository**: `lib/features/auth/data/repositories/auth_repository.dart`
- **Provider**: `lib/features/auth/providers/auth_provider.dart`

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/auth/register` | POST | `register()` | ✅ |
| `/auth/login` | POST | `login()` | ✅ |
| `/auth/refresh` | POST | `refreshToken()` | ✅ |
| `/auth/forgot-password/request` | POST | `forgotPasswordRequest()` | ✅ |
| `/auth/forgot-password/verify` | POST | `verifyOtp()` | ✅ |
| `/auth/forgot-password/reset` | POST | `resetPassword()` | ✅ |
| `/auth/profile` | GET | `getProfile()` | ✅ |

### Models Available:
- `User` - User profile data
- `AuthResponse` - Login/Register response with tokens
- `RegisterRequest` - Registration payload
- `LoginRequest` - Login payload
- `ForgotPasswordRequest` - Password reset request
- `VerifyOtpRequest` - OTP verification
- `ResetPasswordRequest` - Password reset with OTP

---

## 💰 Wallet Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/wallet/data/models/wallet_models.dart`
- **Repository**: `lib/features/wallet/data/repositories/wallet_repository.dart`
- **Provider**: `lib/features/wallet/providers/wallet_provider.dart`

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/wallets/create` | POST | `createWallet()` | ✅ |
| `/wallets/my-wallet` | GET | `getMyWallet()` | ✅ |
| `/wallets/my-wallet/balance` | GET | `getMyWalletBalance()` | ✅ |
| `/wallets/transfer/hbar` | POST | `transferHbar()` | ✅ |
| `/wallets/fund/my-account` | POST | `fundMyAccount()` | ✅ |
| `/wallets/fund/account` | POST | `fundAccount()` | ✅ |
| `/wallets/create-with-balance` | POST | `createWalletWithBalance()` | ✅ |
| `/wallets/{id}` | GET | `getWallet()` | ✅ |
| `/wallets/{id}/balance` | GET | `getWalletBalance()` | ✅ |

### Models Available:
- `Wallet` - Wallet entity
- `WalletResponse` - Enhanced wallet with balance
- `WalletBalance` - HBAR and ZAU balances
- `TransferHbarRequest` - Transfer payload
- `TransferResponse` - Transaction hash response
- `FundAccountRequest` - Funding payload
- `Transaction` - Transaction history

---

## 🐕 Animal Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/animals/data/models/animal_models.dart`
- **Repository**: `lib/features/animals/data/repositories/animals_repository.dart`
- **Provider**: `lib/features/animals/providers/animals_provider.dart`
- **File Upload**: `lib/core/services/file_upload_service.dart`

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/animals` | POST | `createAnimal()` | ✅ |
| `/animals` | GET | `getAnimals()` | ✅ |
| `/animals/{id}` | GET | `getAnimal()` | ✅ |
| `/animals/{id}` | PATCH | `updateAnimal()` | ✅ |
| `/animals/{id}` | DELETE | `deleteAnimal()` | ✅ |
| `/animals/{id}/upload-image` | POST | `uploadAnimalImage()` | ✅ |
| `/animals/{id}/upload-vet-record` | POST | `uploadAnimalVetRecord()` | ✅ |

### Models Available:
- `Animal` - Animal entity with NFT data
- `AnimalOwner` - Owner information
- `CreateAnimalRequest` - Creation payload
- `UpdateAnimalRequest` - Update payload
- `AnimalFilter` - Filtering options
- `AnimalSortBy` - Sorting options

### Special Features:
- **Multipart Upload Support**: Create animals with images directly
- **File Upload Service**: Dedicated service for handling image and document uploads
- Repository methods support both JSON and multipart form data

---

## 💱 Trading Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/trading/data/models/trade_models.dart`
- **Repository**: `lib/features/trading/data/repositories/trading_repository.dart`
- **Provider**: `lib/features/trading/providers/trading_provider.dart`

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/trades/list` | POST | `createTrade()` | ✅ |
| `/trades` | GET | `getTrades()` | ✅ |
| `/trades/{id}` | GET | `getTrade()` | ✅ |
| `/trades/buy/{id}` | POST | `buyAnimal()` | ✅ |
| `/trades/execute/{id}` | POST | `executeTrade()` | ✅ |
| `/trades/cancel/{id}` | POST | `cancelTrade()` | ✅ |

### Models Available:
- `Trade` - Trade entity
- `TradeAnimal` - Animal info in trade
- `TradeUser` - User info in trade
- `CreateTradeRequest` - List animal payload
- `TradeFilter` - Filtering options
- `TradeSortBy` - Sorting options

---

## 🆔 DID Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/did/data/models/did_models.dart` ✨ **NEW**
- **Repository**: `lib/features/did/data/repositories/did_repository.dart` ✨ **NEW**
- **Provider**: `lib/features/did/providers/did_provider.dart` ✨ **NEW**

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/did/my-did` | GET | `getMyDid()` | ✅ |
| `/did/create` | POST | `createDid()` | ✅ |
| `/did/resolve/{did}` | GET | `resolveDid()` | ✅ |
| `/did/credentials` | GET | `getMyCredentials()` | ✅ |
| `/did/credentials/{type}` | GET | `getCredentialsByType()` | ✅ |
| `/did/credentials/issue/kyc` | POST | `issueKycCredential()` | ✅ |
| `/did/credentials/issue/reputation` | POST | `issueReputationCredential()` | ✅ |
| `/did/credentials/issue/veterinary` | POST | `issueVeterinaryCredential()` | ✅ |
| `/did/credentials/verify` | POST | `verifyCredential()` | ✅ |
| `/did/credentials/revoke/{credentialId}` | POST | `revokeCredential()` | ✅ |

### Models Available:
- `DidResponse` - DID document response
- `Credential` - Verifiable credential
- `CredentialSubject` - Credential subject data
- `CredentialsResponse` - List of credentials
- `IssueKycCredentialRequest` - KYC issuance
- `IssueReputationCredentialRequest` - Reputation issuance
- `IssueVeterinaryCredentialRequest` - Veterinary issuance
- `VerifyCredentialRequest` - Credential verification
- `VerifyCredentialResponse` - Verification result
- `RevokeCredentialResponse` - Revocation result

### Enums:
- `CredentialType` - KYC, REPUTATION, VETERINARY
- `KycLevel` - basic, enhanced, premium
- `HealthStatus` - healthy, sick, recovering

### State Management:
The DID provider maintains:
- Current user's DID
- All credentials
- Filtered credentials by type
- Validation status

---

## 🏛️ Admin Collection Endpoints

### Files Involved:
- **API Client**: `lib/core/network/api_client.dart`
- **Models**: `lib/features/admin/data/models/collection_models.dart` ✨ **NEW**
- **Repository**: `lib/features/admin/data/repositories/collections_repository.dart` ✨ **NEW**
- **Provider**: `lib/features/admin/providers/collections_provider.dart` ✨ **NEW**

### Endpoints Integrated:

| Endpoint | Method | API Client Method | Status |
|----------|--------|-------------------|--------|
| `/admin/collections` | POST | `createCollection()` | ✅ |
| `/admin/collections` | GET | `listCollections()` | ✅ |
| `/admin/collections/default` | GET | `getDefaultCollection()` | ✅ |
| `/admin/collections/rotate-if-full` | POST | `rotateCollectionsIfFull()` | ✅ |
| `/admin/collections/{id}/disable` | PATCH | `disableCollection()` | ✅ |
| `/admin/collections/{id}/default` | PATCH | `setCollectionAsDefault()` | ✅ |

### Models Available:
- `Collection` - NFT collection entity
- `CreateCollectionRequest` - Collection creation
- `RotateCollectionRequest` - Rotation settings
- `CollectionStats` - Analytics data
- `CollectionFilter` - Filtering options
- `CollectionSortBy` - Sorting options

### Special Features:
- **Capacity Management**: Track collection fill percentage
- **Auto Rotation**: Rotate when collection is full
- **Stats Calculation**: Total NFTs, active collections, etc.

---

## 📖 Usage Examples

### 1. Authentication Flow

```dart
// Get the auth repository
final authRepo = ref.read(authRepositoryProvider);

// Register a new user
final registerRequest = RegisterRequest(
  email: 'user@example.com',
  password: 'SecurePass123!',
  firstName: 'John',
  lastName: 'Doe',
);
final authResponse = await authRepo.register(registerRequest);

// Login
final loginRequest = LoginRequest(
  email: 'user@example.com',
  password: 'SecurePass123!',
);
final loginResponse = await authRepo.login(loginRequest);

// Get profile
final user = await authRepo.getProfile();
```

### 2. Wallet Operations

```dart
// Get wallet repository
final walletRepo = ref.read(walletRepositoryProvider);

// Create wallet
final wallet = await walletRepo.createWallet();

// Get balance
final balance = await walletRepo.getMyWalletBalance();
print('HBAR: ${balance.hbar}, ZAU: ${balance.zau}');

// Transfer HBAR
final transferRequest = TransferHbarRequest(
  toAccountId: '0.0.123456',
  amount: '10.5',
);
final transferResponse = await walletRepo.transferHbar(transferRequest);
```

### 3. Animal Management with Image Upload

```dart
// Get animals repository
final animalsRepo = ref.read(animalsRepositoryProvider);

// Create animal with image
final request = CreateAnimalRequest(
  name: 'Buddy',
  species: 'DOG',
  breed: 'Golden Retriever',
  age: 3,
  gender: 'MALE',
  description: 'Friendly dog',
);

final imageFile = File('/path/to/image.jpg');
final animal = await animalsRepo.createAnimal(
  request: request,
  imageFile: imageFile,
);

// Upload image to existing animal
final updatedAnimal = await animalsRepo.uploadAnimalImage(
  animalId: animal.id,
  imageFile: imageFile,
);
```

### 4. Trading Operations

```dart
// Get trading repository
final tradingRepo = ref.read(tradingRepositoryProvider);

// List animal for trade
final tradeRequest = CreateTradeRequest(
  animalId: 'animal_123',
  price: 1500.50,
  currency: 'HBAR',
);
final trade = await tradingRepo.createTrade(tradeRequest);

// Buy animal
await tradingRepo.buyAnimal(trade.id);

// Execute trade (atomic swap)
await tradingRepo.executeTrade(trade.id);
```

### 5. DID and Credentials

```dart
// Get DID repository
final didRepo = ref.read(didRepositoryProvider);

// Create DID
final did = await didRepo.createDid();

// Issue KYC credential
final kycResponse = await didRepo.issueKycCredential(
  level: KycLevel.enhanced,
  provider: 'KYC Provider Inc',
  country: 'US',
  documentType: 'passport',
);

// Get all credentials
final credentials = await didRepo.getMyCredentials();

// Verify credential
final isValid = await didRepo.verifyCredential(
  credentials.credentials.first.toJson(),
);

// Issue veterinary credential
await didRepo.issueVeterinaryCredential(
  vetId: 'vet_123',
  vetName: 'Dr. Smith',
  examinationDate: '2024-01-01',
  healthStatus: HealthStatus.healthy,
  vaccinations: ['rabies', 'distemper'],
  animalId: 'animal_123',
);
```

### 6. Using Providers (Recommended)

```dart
// Using DID Provider
final didNotifier = ref.read(didProvider.notifier);

// Get or create DID
await didNotifier.getOrCreateDid();

// Access state
final didState = ref.watch(didProvider);
if (didState.hasDid) {
  print('DID: ${didState.did!.did}');
}

// Issue KYC
await didNotifier.issueKycCredential(
  level: KycLevel.premium,
  provider: 'KYC Inc',
);

// Using Collections Provider (Admin)
final collectionsNotifier = ref.read(collectionsProvider.notifier);

// Load collections
await collectionsNotifier.loadCollections();

// Create collection
await collectionsNotifier.createCollection(
  name: 'Animals Collection',
  symbol: 'ANML',
  maxSupply: 10000,
  isDefault: true,
);

// Access state
final collectionsState = ref.watch(collectionsProvider);
print('Total collections: ${collectionsState.totalCollections}');
print('Active: ${collectionsState.activeCount}');
```

---

## 🔧 Configuration

### API Base URL
Configured in `lib/core/config/environment.dart`:
- **Development**: `http://192.168.1.14:3000` (or from env variable)
- **Staging**: `https://staging-api.zauro.com`
- **Production**: `https://api.zauro.com`

All endpoints are automatically prefixed with `/api/v1`.

### Authentication
JWT tokens are automatically handled by the `AuthInterceptor`:
- Access token stored securely
- Automatic token refresh on 401 errors
- Authorization header added to all authenticated requests

### File Uploads
Handled by dedicated `FileUploadService`:
- Multipart form data support
- Extended timeouts (2 minutes)
- Support for images and documents
- Returns updated entity after upload

---

## ✅ Integration Status Summary

| Category | Endpoints | Status |
|----------|-----------|--------|
| Authentication | 7/7 | ✅ 100% |
| Wallet | 9/9 | ✅ 100% |
| Animals | 7/7 | ✅ 100% |
| Trading | 6/6 | ✅ 100% |
| DID | 10/10 | ✅ 100% |
| Admin Collections | 6/6 | ✅ 100% |
| **TOTAL** | **45/45** | **✅ 100%** |

---

## 🎯 Next Steps

1. **Test Endpoints**: Create unit tests for repositories
2. **Error Handling**: Implement comprehensive error handling in UI
3. **Offline Support**: Add caching for read operations
4. **Real-time Updates**: Consider WebSocket integration for live data
5. **Analytics**: Track API usage and performance

---

## 📝 Notes

- All models have JSON serialization support via `json_serializable`
- Code generation is handled by `build_runner`
- Retrofit is used for type-safe API calls
- Riverpod is used for state management
- File uploads use `dio` with multipart form data
- All endpoints support proper error handling and response transformation

---

## 🛠️ Maintenance

To regenerate models after changes:
```bash
cd Zauro_app/frontend
flutter pub run build_runner build --delete-conflicting-outputs
```

To watch for changes during development:
```bash
flutter pub run build_runner watch
```

---

**Last Updated**: October 27, 2025  
**Integration Status**: ✅ Complete (45/45 endpoints integrated)


