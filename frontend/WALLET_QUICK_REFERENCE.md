# Wallet Features - Quick Reference Card 🚀

## 🎯 5-Second Overview
Your wallet now has **Fund, Send, Receive, Trade NFTs, and History** - all with QR scanning and biometric security!

## 📱 Main Actions

### Fund Wallet
```
Wallet Screen → "Fund" button → Enter amount → Fund
```
**File**: `lib/features/wallet/presentation/widgets/fund_wallet_dialog.dart`

### Send Money
```
Wallet Screen → "Send" → Select asset → Scan QR/Enter ID → Amount → Authenticate
```
**File**: `lib/features/wallet/presentation/widgets/enhanced_send_dialog.dart`

### Receive Money
```
Wallet Screen → "Receive" → Show/Copy QR code
```
**File**: `lib/features/wallet/presentation/widgets/receive_qr_dialog.dart`

### Trade NFTs
```
Wallet Screen → "Trade" → Browse/My NFTs → Buy/List
```
**File**: `lib/features/wallet/presentation/screens/nft_marketplace_screen.dart`

### View History
```
Wallet Screen → "History" → Filter by type → View details
```
**File**: `lib/features/wallet/presentation/screens/transaction_history_screen.dart`

## 🔧 Quick Setup

```bash
# Install dependencies
cd frontend && flutter pub get

# Run app
flutter run
```

## 📋 Permissions Needed

**Android**: Camera, Internet, Biometric  
**iOS**: Camera, Face ID

## 🎨 Key Features

| Feature | Icon | Color | Action |
|---------|------|-------|--------|
| Fund | ➕ | Green | Add HBAR |
| Send | ⬆️ | Orange | Transfer out |
| Receive | ⬇️ | Blue | Get QR |
| Trade | ⟲ | Purple | NFT market |
| History | 📋 | Gray | View txns |

## 🔐 Security

- ✅ Biometric auth required for sends
- ✅ Balance validation
- ✅ Account format checks
- ✅ Confirmation dialogs

## 🐛 Quick Fixes

| Issue | Solution |
|-------|----------|
| QR won't open | Check camera permissions |
| Biometric fails | Use PIN fallback |
| Balance wrong | Pull to refresh |
| NFTs not loading | Check backend connection |

## 📁 File Structure

```
wallet/
├── presentation/
│   ├── screens/
│   │   ├── wallet_screen.dart          (Main screen)
│   │   ├── transaction_history_screen.dart
│   │   └── nft_marketplace_screen.dart
│   └── widgets/
│       ├── fund_wallet_dialog.dart
│       ├── enhanced_send_dialog.dart
│       ├── receive_qr_dialog.dart
│       ├── qr_scanner_widget.dart
│       ├── nft_detail_modal.dart
│       └── list_nft_dialog.dart
├── providers/
│   └── wallet_provider.dart
└── data/
    └── models/wallet_models.dart
```

## 🌐 API Endpoints

| Action | Method | Endpoint |
|--------|--------|----------|
| Fund | POST | `/wallets/fund/my-account` |
| Send | POST | `/wallets/transfer/hbar` |
| Balance | GET | `/wallets/my-wallet/balance` |
| List NFT | POST | `/trades/list` |
| Buy NFT | POST | `/trades/buy/{id}` |
| History | GET | `/transactions` |

## 💡 Pro Tips

1. **Enable biometrics** for quick secure transfers
2. **Save QR codes** for easy sharing
3. **Check history** after each transaction
4. **Pull down** to refresh balance
5. **Toggle visibility** to hide balance

## 📚 Full Docs

- **Implementation**: `WALLET_FEATURES_IMPLEMENTATION.md`
- **Quick Start**: `WALLET_FEATURES_QUICKSTART.md`
- **Summary**: `INTEGRATION_SUMMARY.md`

---

**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Last Updated**: January 2025

