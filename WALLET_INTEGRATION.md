# Wallet Integration & Auto-Connection Guide

## Overview
The app now automatically creates/connects wallet and loads balance when user logs in.

## Implementation Details

### 1. App Lifecycle Provider (`core/providers/app_lifecycle_provider.dart`)

This provider automatically:
- Creates wallet if it doesn't exist when user logs in
- Loads wallet balance immediately after wallet creation
- Clears wallet data on logout

```dart
// Listens to auth state changes
_ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  if (next.user != null && previous?.user == null) {
    _onUserLogin(); // Auto-initialize wallet
  }
  
  if (next.user == null && previous?.user != null) {
    _onUserLogout(); // Clear wallet data
  }
});
```

### 2. Dashboard Auto-Loading (`features/home/presentation/screens/dashboard_screen.dart`)

The dashboard automatically loads balance if not already loaded:

```dart
ref.listen<AsyncValue<WalletBalance?>>(walletBalanceProvider, (previous, next) {
  // Auto-load if user logged in but balance not loaded
  if (user != null && !next.isLoading && !next.hasValue) {
    ref.read(walletBalanceProvider.notifier).getBalance();
  }
});
```

### 3. Main App Initialization (`main.dart`)

The lifecycle provider is watched in the main app to ensure it's always active:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Initialize app lifecycle manager
  ref.watch(appLifecycleProvider);
  
  return MaterialApp.router(...);
}
```

## User Flow

### Login Flow:
1. User enters credentials and clicks "Login"
2. `AuthProvider` authenticates user
3. `AppLifecycleProvider` detects user login
4. Wallet is auto-created (if doesn't exist) or loaded
5. Balance is auto-loaded
6. User is navigated to Dashboard
7. Dashboard displays HBAR and ZAU balances

### Dashboard Display:
```
┌─────────────────────┐
│   Welcome back!     │
│   John Doe          │
└─────────────────────┘

┌─────────┐ ┌─────────┐
│ 🪙 HBAR │ │ 💰 ZAU  │
│ 100.50  │ │ 1000.00 │
└─────────┘ └─────────┘
```

## API Endpoints Used

### On Login:
1. `POST /api/v1/auth/login` - Authenticate user
2. `GET /api/v1/wallets/my-wallet` - Check if wallet exists
3. `POST /api/v1/wallets/create` - Create if doesn't exist
4. `GET /api/v1/wallets/my-wallet/balance` - Get current balances

### On Dashboard:
1. `GET /api/v1/wallets/my-wallet/balance` - Display balances
2. `GET /api/v1/trades` - Show marketplace items

## Balance Format

### From API:
```json
{
  "hbar": "100.12345678",
  "zau": "1000.50"
}
```

### In App:
```dart
class WalletBalance {
  final String hbar;
  final String zau;
  
  // Convenience getters
  double get hbarBalance => double.tryParse(hbar) ?? 0.0;
  double get zauBalance => double.tryParse(zau) ?? 0.0;
  
  String get formattedHbarBalance => '$hbar HBAR';
  String get formattedZauBalance => '$zau ZAU';
}
```

## Error Handling

### Wallet Creation Fails:
- App continues to function
- Error is logged but not shown to user
- User can manually create wallet from Wallet screen

### Balance Loading Fails:
- Shows "0.00" as placeholder
- User can pull-to-refresh to retry
- Error message shown in dashboard stats section

### Network Issues:
- All API calls have 30-second timeout
- Automatic retry on connection errors
- Graceful degradation (shows last known balance)

## Testing

### Manual Test:
1. Clear app data
2. Register new user
3. Verify wallet is auto-created
4. Verify balance is displayed on dashboard
5. Pull-to-refresh to update balance
6. Logout and login again
7. Verify balance persists

### Expected Behavior:
✅ Wallet created on first login
✅ Balance loads within 2-3 seconds
✅ Dashboard shows HBAR and ZAU
✅ Pull-to-refresh updates balance
✅ Logout clears wallet state
✅ Login restores wallet and balance

## Troubleshooting

### Issue: Balance shows 0.00
**Solution:**
1. Check if wallet is created: `GET /api/v1/wallets/my-wallet`
2. Fund account: `POST /api/v1/wallets/fund/my-account`
3. Refresh balance: Pull-to-refresh on dashboard

### Issue: Wallet not created
**Solution:**
1. Check backend is running on `http://localhost:3000`
2. Verify JWT token in API calls
3. Check Hedera testnet connection
4. Manually create: `POST /api/v1/wallets/create`

### Issue: Balance not updating
**Solution:**
1. Clear app cache
2. Force refresh: Pull-to-refresh
3. Check API response format matches expected structure
4. Verify balance endpoint returns valid JSON

## Performance

### Initial Load Time:
- Wallet creation: ~2-3 seconds (includes Hedera network call)
- Balance loading: ~500ms - 1 second
- Total login-to-dashboard: ~3-4 seconds

### Caching:
- Balance cached in memory (StateNotifier)
- Wallet data cached in memory
- No disk caching (always fresh from API)

### Optimization:
- Parallel API calls where possible
- Debounced refresh (prevent spam)
- Error recovery with exponential backoff

## Security

### Token Management:
- JWT tokens stored securely in device storage
- Automatic token refresh when expired
- Tokens cleared on logout

### Sensitive Data:
- Private keys never exposed to frontend
- All wallet operations server-side
- Balance data not cached on disk

## Future Enhancements

### Planned Features:
1. Transaction history display
2. Real-time balance updates (WebSocket)
3. Multi-wallet support
4. Offline mode with cached balance
5. Biometric authentication for transfers
6. Push notifications for balance changes

### Potential Issues:
1. Race condition if multiple requests simultaneously
2. Network latency on slow connections
3. Hedera network downtime

### Solutions:
1. Request queueing and deduplication
2. Loading states and retry logic
3. Fallback to cached data with warning

