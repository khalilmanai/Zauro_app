# Wallet Features Implementation Guide

## 🎉 Overview

This document describes the comprehensive wallet features that have been integrated into the Zauro App Flutter frontend. All features are connected to the backend API and Hedera HTS blockchain.

## ✅ Implemented Features

### 1. 🪙 Wallet Overview
- **Live Balance Display**: Real-time HBAR and ZAU token balances
- **Auto-refresh**: Balance updates automatically on wallet actions
- **Manual Refresh**: Pull-to-refresh or manual refresh button
- **Responsive UI**: Optimized for both mobile and tablet devices
- **Balance Visibility Toggle**: Hide/show balance for privacy
- **USD Conversion**: Approximate USD value displayed

**Location**: `lib/features/wallet/presentation/screens/wallet_screen.dart`

### 2. 💰 Fund & Deposit
- **Fund Wallet Dialog**: Modal dialog for adding HBAR to wallet
- **Amount Input**: Decimal input with validation
- **Memo Support**: Optional transaction memo field
- **Success Feedback**: Visual confirmation with transaction hash
- **Error Handling**: Comprehensive error messages

**Location**: `lib/features/wallet/presentation/widgets/fund_wallet_dialog.dart`

**API Endpoint**: `POST /api/v1/wallets/fund/my-account`

**How to Use**:
1. Click the "Fund" button on wallet screen
2. Enter amount and optional memo
3. Click "Fund Wallet"
4. Wait for confirmation

### 3. 🔁 Send & Receive Value

#### Send Features
- **Multi-Asset Support**: Send HBAR or ZAU tokens
- **QR Code Scanning**: Scan recipient's wallet QR code
- **Manual Entry**: Type recipient's Hedera account ID
- **Amount Validation**: Checks against available balance
- **Biometric Authentication**: Required for security
- **Transaction Memo**: Optional message with transfer

**Location**: `lib/features/wallet/presentation/widgets/enhanced_send_dialog.dart`

**API Endpoint**: `POST /api/v1/wallets/transfer/hbar`

**How to Use**:
1. Click "Send" button
2. Select asset (HBAR or ZAU)
3. Enter or scan recipient address
4. Enter amount
5. Authenticate with biometrics
6. Confirm transaction

#### Receive Features
- **QR Code Generation**: Display your wallet address as QR code
- **Copy to Clipboard**: One-tap copy of account ID
- **Instructions**: Help text for receiving funds

**Location**: `lib/features/wallet/presentation/widgets/receive_qr_dialog.dart`

**How to Use**:
1. Click "Receive" button
2. Show QR code to sender or copy account ID
3. Share with sender

### 4. 📸 QR Code Integration
- **QR Scanner Widget**: Full-screen camera scanner
- **Torch Support**: Toggle flashlight
- **Camera Switch**: Front/back camera switching
- **Visual Feedback**: Scanning area overlay with corner indicators
- **Auto-detection**: Automatically processes scanned QR codes

**Location**: `lib/features/wallet/presentation/widgets/qr_scanner_widget.dart`

**Dependencies**:
- `mobile_scanner: ^5.2.3` - QR code scanning
- `qr_flutter: ^4.1.0` - QR code generation

### 5. 🤝 Peer-to-Peer NFT Exchange

#### Marketplace Screen
- **Browse NFTs**: View all listed NFTs in grid layout
- **My NFTs**: View owned NFT collection
- **NFT Cards**: Display image, name, price, and token info
- **Filtering**: Tab-based navigation (Browse/My NFTs)

**Location**: `lib/features/wallet/presentation/screens/nft_marketplace_screen.dart`

#### NFT Detail Modal
- **Full NFT Information**: Image, description, properties, seller info
- **Purchase Button**: Buy NFT with selected currency
- **Property Display**: Species, breed, age, etc.
- **Seller Profile**: Display seller information

**Location**: `lib/features/wallet/presentation/widgets/nft_detail_modal.dart`

#### List NFT Dialog
- **Price Setting**: Set NFT listing price
- **Currency Selection**: Choose HBAR or ZAU
- **Listing Confirmation**: Visual feedback on successful listing
- **Cancel Listing**: Option to delist NFT

**Location**: `lib/features/wallet/presentation/widgets/list_nft_dialog.dart`

**API Endpoints**:
- `GET /api/v1/trades` - Get all listed NFTs
- `POST /api/v1/trades/list` - List NFT for sale
- `POST /api/v1/trades/buy/{id}` - Purchase NFT
- `POST /api/v1/trades/execute/{id}` - Execute atomic swap
- `POST /api/v1/trades/cancel/{id}` - Cancel listing

**How to Use (Buying)**:
1. Click "Trade" button on wallet screen
2. Browse available NFTs
3. Tap NFT to view details
4. Click "Purchase" and confirm

**How to Use (Selling)**:
1. Click "Trade" button
2. Switch to "My NFTs" tab
3. Tap NFT you own
4. Click "List for Sale"
5. Enter price and currency
6. Confirm listing

### 6. 📜 Transaction History
- **Transaction List**: View all wallet transactions
- **Tab Filtering**: All, Sent, Received, Trades, NFTs
- **Transaction Types**: SEND, RECEIVE, TRADE, NFT_MINT, NFT_TRANSFER
- **Status Indicators**: Confirmed, Pending, Failed
- **Date Formatting**: Relative time (e.g., "2h ago") or full date
- **Detail View**: Full transaction information modal
- **Copyable Fields**: Copy transaction hash, addresses

**Location**: `lib/features/wallet/presentation/screens/transaction_history_screen.dart`

**How to Use**:
1. Click "History" button on wallet screen
2. Browse transactions by category
3. Tap transaction for full details
4. Copy transaction hash or addresses

### 7. 🔐 Secure Transfers

#### Biometric Authentication
- **Multi-method Support**: Fingerprint, Face ID, PIN
- **Device Compatibility Check**: Validates biometric availability
- **Fallback Options**: PIN/Password if biometrics unavailable
- **Transaction Confirmation**: Required before sensitive operations

**Location**: `lib/core/services/biometric_auth_service.dart`

**Dependencies**: `local_auth: ^2.1.8`

**Security Features**:
- ✅ Biometric confirmation before transfers
- ✅ Confirmation dialogs for trades
- ✅ Secure wallet state management
- ✅ Protected sensitive data display

## 📱 Screen Flow

```
Wallet Screen
├── Fund → Fund Wallet Dialog → Success
├── Send → Enhanced Send Dialog → QR Scanner (optional) → Biometric Auth → Success
├── Receive → Receive QR Dialog → Copy/Share
├── Trade → NFT Marketplace
│   ├── Browse NFTs → NFT Detail → Purchase
│   └── My NFTs → List NFT Dialog → Listed
└── History → Transaction History → Transaction Details
```

## 🎨 UI/UX Features

### Responsive Design
- ✅ Mobile-optimized (< 600px width)
- ✅ Tablet-optimized (≥ 600px width)
- ✅ Dynamic font sizes
- ✅ Adaptive layouts

### Dark Mode Support
- ✅ All screens support dark/light themes
- ✅ Dynamic color scheme
- ✅ Proper contrast ratios

### Animations
- ✅ Fade-in animations on load
- ✅ Smooth transitions
- ✅ Loading states
- ✅ Pull-to-refresh indicators

### Accessibility
- ✅ Semantic labels
- ✅ Touch targets (min 44x44)
- ✅ High contrast text
- ✅ Screen reader support

## 🔧 Technical Implementation

### State Management
- **Provider**: Riverpod for reactive state
- **Async Handling**: AsyncValue for loading/error states
- **Auto-refresh**: State updates on successful actions

### API Integration
- **Base URL**: Configured in `AppConfig`
- **Authentication**: JWT tokens via interceptors
- **Error Handling**: Network exceptions with user-friendly messages
- **Retry Logic**: Automatic retry on network failures

### Data Models
All models are defined in `lib/features/wallet/data/models/wallet_models.dart`:
- `WalletResponse` - Wallet information
- `WalletBalance` - Balance data (HBAR, ZAU)
- `Transaction` - Transaction details
- `TransferHbarRequest` - Transfer request DTO
- `FundAccountRequest` - Funding request DTO

### Validation
- ✅ Hedera account ID format (0.0.XXXXXX)
- ✅ Amount validation (positive numbers, sufficient balance)
- ✅ Form validation with error messages
- ✅ Self-transfer prevention

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Generate Code (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Backend URL
Update `lib/core/config/app_config.dart`:
```dart
static const String apiUrl = 'your-backend-url';
```

### 4. Run the App
```bash
flutter run
```

## 📋 Prerequisites

### Required Permissions (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### Required Permissions (iOS)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes</string>
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to secure your transactions</string>
```

## 🔍 Testing Features

### Fund Wallet
1. Open wallet screen
2. Click "Fund" button
3. Enter amount: `10.5`
4. Add memo: "Test funding"
5. Click "Fund Wallet"
6. Verify success message and balance update

### Send with QR Scanner
1. Click "Send" button
2. Select asset (HBAR)
3. Click QR scanner icon
4. Scan recipient's QR code
5. Enter amount: `5.0`
6. Complete biometric authentication
7. Verify transaction success

### NFT Trading
1. Click "Trade" button
2. Browse available NFTs
3. Click an NFT to view details
4. Click "Purchase"
5. Confirm transaction
6. Verify NFT appears in "My NFTs"

### List NFT for Sale
1. Navigate to "My NFTs" tab
2. Click owned NFT
3. Click "List for Sale"
4. Enter price: `100`
5. Select currency: HBAR
6. Confirm listing
7. Verify NFT shows "Listed" badge

## 🐛 Troubleshooting

### QR Scanner Not Working
- Check camera permissions
- Ensure device has camera
- Verify `mobile_scanner` package installed

### Biometric Auth Fails
- Check if device supports biometrics
- Verify biometric enrollment
- Fallback to PIN/Password

### API Errors
- Verify backend is running
- Check JWT token validity
- Confirm network connectivity
- Review API endpoint URLs

## 📚 File Structure

```
lib/features/wallet/
├── data/
│   ├── models/
│   │   └── wallet_models.dart
│   └── repositories/
│       └── wallet_repository.dart
├── presentation/
│   ├── screens/
│   │   ├── wallet_screen.dart
│   │   ├── transaction_history_screen.dart
│   │   └── nft_marketplace_screen.dart
│   └── widgets/
│       ├── fund_wallet_dialog.dart
│       ├── enhanced_send_dialog.dart
│       ├── receive_qr_dialog.dart
│       ├── qr_scanner_widget.dart
│       ├── nft_detail_modal.dart
│       └── list_nft_dialog.dart
└── providers/
    └── wallet_provider.dart

lib/core/
└── services/
    └── biometric_auth_service.dart
```

## 🎯 Next Steps & Future Enhancements

### Potential Improvements
- [ ] Transaction history pagination
- [ ] Real-time balance updates via WebSocket
- [ ] Multiple wallet support
- [ ] Transaction export (CSV/PDF)
- [ ] Advanced filtering (date range, amount)
- [ ] NFT metadata caching
- [ ] Offline mode support
- [ ] Push notifications for transactions

### Known Limitations
- Transaction history uses mock data (needs API integration)
- NFT images require network connection
- Biometric auth requires device support

## 🔗 Related Documentation
- [Backend API Documentation](../backend-endpoints.md)
- [Wallet Integration Guide](WALLET_INTEGRATION.md)
- [UI Refactor Summary](UI_REFACTOR_SUMMARY.md)

## 📞 Support
For issues or questions, please refer to the main project README or contact the development team.

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Author**: Zauro Development Team

