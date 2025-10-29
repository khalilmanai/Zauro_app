# 🔐 Hedera Account Setup - Fund Your Account

## ⚠️ Current Issue

Your app is running but can't create NFT collections because your Hedera account **needs HBAR** to pay for transactions.

**Error:** `INSUFFICIENT_PAYER_BALANCE`

**Account:** `0.0.6159428`  
**Network:** Hedera Testnet

---

## ✅ How to Get Free Testnet HBAR

### Option 1: Hedera Portal (Recommended)

1. **Go to**: https://portal.hedera.com
2. **Click**: "Get testnet HBAR" (top right)
3. **Select**: Testnet
4. **Enter your account**: `0.0.6159428`
5. **Request**: 100 HBAR (free!)
6. **Copy the transaction ID**
7. **Wait**: ~5-10 seconds for confirmation

### Option 2: Dragonglass Faucet

1. **Go to**: https://www.dragonglass.me/hedera/testnet-faucet
2. **Enter account ID**: `0.0.6159428`
3. **Click**: "Send HBAR"
4. **Wait**: Transaction confirms in seconds

### Option 3: HashPack Wallet

1. **Install**: HashPack wallet (https://hashpack.app)
2. **Import** your account using the private key
3. **Request** testnet HBAR from the wallet
4. **Use** for all your transactions

---

## 💰 How Much HBAR Do You Need?

**Minimum:** 10 HBAR (for testing)  
**Recommended:** 50-100 HBAR (for production)  
**Why:** Each transaction costs ~0.00001 HBAR in fees

---

## 🎯 After Funding

Once funded, your app will:

1. ✅ Create default NFT collection on startup
2. ✅ Mint animal NFTs
3. ✅ Create Hedera accounts for users
4. ✅ Transfer HBAR
5. ✅ All blockchain operations work

---

## 🔍 Verify Your Balance

### Using your API:
```bash
curl https://your-url.railway.app/api/v1/wallets/my-wallet/balance \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Using HashScan:
1. Go to: https://hashscan.io/testnet
2. Search: `0.0.6159428`
3. Check balance in HBAR

---

## 📝 Environment Variables

Make sure these are set in Railway:

```env
HEDERA_ACCOUNT_ID=0.0.6159428
HEDERA_PRIVATE_KEY=302e0201...
HEDERA_NETWORK=testnet
```

---

## 🚨 Important Notes

1. **Testnet HBAR is FREE** - no real money needed
2. **Mainnet costs real HBAR** - switch when ready for production
3. **Keep your private key SECRET** - never share it
4. **Faucet has limits** - request reasonable amounts

---

## ✅ Quick Checklist

- [ ] Go to Hedera Portal faucet
- [ ] Enter account: `0.0.6159428`
- [ ] Request 50-100 HBAR
- [ ] Wait for confirmation
- [ ] Restart your app or Railway
- [ ] Verify collections work

---

## 🆘 Still Having Issues?

If balance shows but you still get errors:

1. **Check transaction fees**: You need at least 1 HBAR buffer
2. **Verify network**: Make sure it's testnet, not mainnet
3. **Check private key**: Must match the account ID
4. **Try small amounts first**: Test with 10 HBAR

---

**That's it!** Once you fund your account, everything will work! 🎉

