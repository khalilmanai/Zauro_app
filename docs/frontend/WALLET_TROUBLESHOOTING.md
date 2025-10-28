# Wallet Integration Troubleshooting Guide

## 🐛 Common Issues & Solutions

### Issue 1: "Failed to load wallet data" Error

#### Possible Causes:
1. **Wallet doesn't exist yet**
2. **Backend server not running**
3. **Authentication token expired**
4. **Network connectivity issues**
5. **Backend API endpoint mismatch**

#### Solutions:

##### 1. Check if backend is running
```bash
# Check if backend is accessible
curl http://localhost:3000/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

##### 2. Verify user is logged in
- Check console logs for auth token
- Look for `Authorization: Bearer ...` in network logs
- Token should be fresh (not expired)

##### 3. Manually create wallet via API
```bash
# Create wallet for logged-in user
curl -X POST http://localhost:3000/api/v1/wallets/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

##### 4. Check console logs for detailed error
Look for these log patterns:
```
🔄 Initializing wallet...
✅ Wallet loaded successfully
🔄 Loading wallet balance...
✅ Wallet balance loaded successfully
```

If you see:
```
❌ Error loading wallet balance: ...
```
Read the full error message for clues.

### Issue 2: Balance Shows 0.00 After Login

#### Cause:
- Wallet exists but hasn't been funded yet
- Default balance is 0 HBAR

#### Solution:
Fund your wallet via backend:
```bash
# Fund your wallet with 100 HBAR
curl -X POST http://localhost:3000/api/v1/wallets/my-wallet/fund \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "amount": "100"
  }'
```

### Issue 3: "Null check operator used on a null value"

#### Cause:
- User object or wallet data is null
- Accessing properties before data loads

#### Solution:
Already fixed in latest code with null safety:
```dart
// Safe access
user?.avatarUrl != null && user?.avatarUrl?.isNotEmpty == true
  ? NetworkImage(user!.avatarUrl!)
  : null

// Safe balance display
balance?.displayHbar ?? '0.00'
```

### Issue 4: Balance Parsing Error (ℏ symbol)

#### Cause:
Backend returns `"10 ℏ"` instead of `"10"`

#### Solution:
Already fixed with regex parsing:
```dart
double get hbarBalance {
  final cleanHbar = hbar.replaceAll(RegExp(r'[^0-9.]'), '').trim();
  return double.tryParse(cleanHbar) ?? 0.0;
}
```

Handles:
- `"10 ℏ"` → 10.0
- `"10.5 HBAR"` → 10.5
- `"1000"` → 1000.0

### Issue 5: Wallet Not Auto-Creating

#### Debugging Steps:

1. **Check app lifecycle logs:**
```
Look for:
🔄 Initializing wallet...
⚠️ Error getting wallet: ...
🆕 Creating new wallet...
```

2. **Verify backend endpoint:**
```bash
# Test wallet creation manually
curl -X POST http://localhost:3000/api/v1/wallets/create \
  -H "Authorization: Bearer YOUR_TOKEN"
```

3. **Check for rate limiting:**
```
Look in response headers:
x-ratelimit-limit: 10
x-ratelimit-remaining: 9
```

4. **Verify user has permission:**
- User must be authenticated
- JWT token must be valid
- User account must be active

### Issue 6: Balance Not Updating After Transfer

#### Solution:
Pull to refresh or tap retry button.

Manual refresh:
```dart
ref.read(walletBalanceProvider.notifier).refresh();
```

### Issue 7: Backend Connection Refused

#### Debugging:

1. **Check backend URL in app config:**
```dart
// Should be for Android emulator:
baseUrl: 'http://10.0.2.2:3000/api/v1'

// For iOS simulator:
baseUrl: 'http://localhost:3000/api/v1'

// For real device:
baseUrl: 'http://YOUR_COMPUTER_IP:3000/api/v1'
```

2. **Verify backend is listening:**
```bash
netstat -an | findstr :3000  # Windows
netstat -an | grep 3000      # Linux/Mac
```

3. **Check firewall settings:**
- Allow port 3000 through firewall
- Disable antivirus temporarily to test

## 📊 Diagnostic Commands

### Check All Endpoints
```bash
# 1. Check authentication
curl http://localhost:3000/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_TOKEN"

# 2. Check wallet
curl http://localhost:3000/api/v1/wallets/my-wallet \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Check balance
curl http://localhost:3000/api/v1/wallets/my-wallet/balance \
  -H "Authorization: Bearer YOUR_TOKEN"

# 4. Check DID
curl http://localhost:3000/api/v1/did/my-did \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get JWT Token from App
Add this to your login success handler:
```dart
print('JWT Token: ${response.accessToken}');
```

Or check Flutter console for:
```
Authorization: Bearer eyJhbGc...
```

## 🔍 Debug Checklist

When reporting wallet issues, provide:

- [ ] Full error message from console
- [ ] Backend server status (running/stopped)
- [ ] Network logs showing API calls
- [ ] JWT token (first/last 10 chars only)
- [ ] User account info (ID, email)
- [ ] Device/emulator type
- [ ] Flutter version
- [ ] Backend response status codes

## 🚀 Quick Fix Commands

### Restart Everything
```bash
# Stop backend
Ctrl+C

# Restart backend
cd Zauro_app
npm run start:dev

# Hot restart Flutter app
Press 'R' in terminal or IDE
```

### Clear App Data (Flutter)
```bash
# Android
flutter run --clear-cache
adb shell pm clear com.zauro.app

# iOS
flutter run --clear-cache
# Then delete app from simulator
```

### Reset Database (Backend)
```bash
cd Zauro_app
npx prisma migrate reset
npx prisma db seed
```

## 📝 Logs to Monitor

### Flutter Console:
```
🔄 Initializing wallet...
✅ Wallet loaded successfully
🔄 Loading wallet balance...
✅ Wallet balance loaded successfully
```

### Backend Logs:
```
GET /api/v1/wallets/my-wallet 200
GET /api/v1/wallets/my-wallet/balance 200
POST /api/v1/wallets/create 201
```

### Network Logs:
```
I/flutter: *** Request ***
I/flutter: uri: http://10.0.2.2:3000/api/v1/wallets/my-wallet/balance
I/flutter: method: GET
I/flutter: *** Response ***
I/flutter: statusCode: 200
I/flutter: Response Text: {"hbar":"10 ℏ","zau":"0"}
```

## 🎯 Success Indicators

When everything works:
1. ✅ Login successful
2. ✅ Wallet auto-created/loaded
3. ✅ Balance displayed on dashboard
4. ✅ No error messages
5. ✅ Pull-to-refresh works
6. ✅ Tap wallet card navigates to wallet screen

## 🆘 Still Having Issues?

If none of these solutions work:

1. **Check GitHub issues**
2. **Review backend logs in detail**
3. **Test with Postman/curl first**
4. **Verify database connection**
5. **Check Hedera testnet status**
6. **Review environment variables**

### Contact Support With:
- Screenshots of error
- Full console logs (Flutter + Backend)
- Steps to reproduce
- Device/OS information
- Network diagnostic results

