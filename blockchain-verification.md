# 🔗 Blockchain Verification Guide
# How to verify NFT collections and minting on Hedera

## 🌐 Hedera Explorer Access

### Testnet Explorer
- **URL**: https://hashscan.io/testnet
- **Search**: Use Token ID or Account ID to verify transactions

### Mainnet Explorer (when deployed)
- **URL**: https://hashscan.io/mainnet

---

## 🔍 Verification Steps

### 1. Verify Collection Creation
1. Go to https://hashscan.io/testnet
2. Search for your collection Token ID (e.g., `0.0.1234567`)
3. Verify:
   - ✅ Token Name matches your collection name
   - ✅ Token Symbol matches your collection symbol
   - ✅ Token Type is "Non-Fungible Unique"
   - ✅ Treasury Account is your operator account
   - ✅ Max Supply (if set) matches your configuration

### 2. Verify NFT Minting
1. In the collection page, click on "NFTs" tab
2. Verify:
   - ✅ NFT serial numbers are sequential
   - ✅ NFT metadata contains animal information
   - ✅ NFTs are owned by correct wallet addresses
   - ✅ Minting transactions show correct timestamps

### 3. Verify Account Balances
1. Search for wallet Account ID (e.g., `0.0.9876543`)
2. Verify:
   - ✅ Account exists and is active
   - ✅ HBAR balance is correct
   - ✅ Token associations show your collections
   - ✅ Transaction history shows minting/transfers

### 4. Verify Transactions
1. Click on specific transaction IDs
2. Verify:
   - ✅ Transaction status is "SUCCESS"
   - ✅ Transaction fee is reasonable
   - ✅ Sender/receiver accounts are correct
   - ✅ Transaction memo contains relevant information

---

## 🛠️ Manual Verification Commands

### Using Hedera SDK (if you have Node.js)
```bash
# Install Hedera SDK
npm install @hashgraph/sdk

# Create verification script
node verify-blockchain.js
```

### Using curl/API calls
```bash
# Get account balance
curl "https://testnet.mirrornode.hedera.com/api/v1/accounts/0.0.1234567"

# Get token info
curl "https://testnet.mirrornode.hedera.com/api/v1/tokens/0.0.1234567"

# Get NFT info
curl "https://testnet.mirrornode.hedera.com/api/v1/tokens/0.0.1234567/nfts/1"
```

---

## 📊 Expected Results

### Collection Verification
- **Token Type**: Non-Fungible Unique
- **Supply Type**: Finite (if maxSupply set) or Infinite
- **Admin Key**: Your operator account
- **Supply Key**: Your operator account
- **Treasury**: Your operator account

### NFT Verification
- **Serial Numbers**: Sequential (1, 2, 3, ...)
- **Metadata**: Compressed animal data (100 bytes max)
- **Owner**: User's wallet account ID
- **Creation Time**: Matches database timestamps

### Account Verification
- **Status**: Active
- **Balance**: HBAR amount matches API response
- **Associations**: Includes your collection tokens
- **Transactions**: Shows minting and transfer operations

---

## 🚨 Common Issues to Check

### Collection Issues
- ❌ Collection not created on blockchain
- ❌ Wrong token type (should be Non-Fungible Unique)
- ❌ Missing admin/supply keys
- ❌ Incorrect treasury account

### NFT Issues
- ❌ NFT not minted (missing from collection)
- ❌ Wrong owner account
- ❌ Missing or corrupted metadata
- ❌ Serial number not sequential

### Account Issues
- ❌ Account not created
- ❌ Wrong balance
- ❌ Missing token associations
- ❌ Transaction failures

---

## 🔧 Troubleshooting

### If Collection Not Found
1. Check if collection was actually created
2. Verify Token ID in database
3. Check Hedera network (testnet vs mainnet)
4. Verify operator account has sufficient HBAR

### If NFT Not Found
1. Check if minting transaction succeeded
2. Verify serial number in database
3. Check if NFT was burned
4. Verify collection Token ID

### If Balance Wrong
1. Check recent transactions
2. Verify account ID
3. Check for pending transactions
4. Verify network connectivity

---

## 📈 Monitoring Dashboard

### Key Metrics to Track
- **Collections Created**: Total number of collections
- **NFTs Minted**: Total NFTs across all collections
- **Active Wallets**: Number of user wallets
- **Transaction Volume**: HBAR transferred
- **Collection Usage**: Percentage of max supply used

### Real-time Monitoring
- **Hedera Mirror Node**: Real-time blockchain data
- **Database Queries**: Local data verification
- **API Health**: Service availability
- **Error Logs**: Failed transactions

---

## ✅ Verification Checklist

### Database ✅
- [ ] User created successfully
- [ ] Wallet created with Hedera account ID
- [ ] Collection created in database
- [ ] Animal/NFT record created
- [ ] Trade record created (if applicable)

### Blockchain ✅
- [ ] Collection exists on Hedera
- [ ] NFT minted successfully
- [ ] NFT owned by correct account
- [ ] Transaction fees paid
- [ ] Metadata stored correctly

### API ✅
- [ ] All endpoints respond correctly
- [ ] Authentication works
- [ ] Data returned matches database
- [ ] Error handling works
- [ ] Rate limiting functions

### Integration ✅
- [ ] Database and blockchain data match
- [ ] NFT ownership synchronized
- [ ] Collection rotation works
- [ ] Trading system functions
- [ ] File uploads work
