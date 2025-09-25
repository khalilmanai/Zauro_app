# 🧪 Zauro Marketplace Testing Guide

## 🎯 **Complete Testing Setup with Pre-configured Accounts**

This guide provides you with **ready-to-use test accounts** and **sample data** to test the entire Zauro Marketplace application without any setup hassle!

---

## 🚀 **Quick Start - Get Testing in 3 Steps**

### **Step 1: Seed the Database**
```bash
# Run the seeding script to create test accounts and sample data
npm run db:seed
```

### **Step 2: Start the Backend**
```bash
# Start the NestJS backend server
npm run start:dev
```

### **Step 3: Start Testing!**
Use the test accounts below to immediately start testing all features.

---

## 🔑 **Ready-to-Use Test Accounts**

### **🔴 Admin Account**
```
Email: admin@zauro.com
Password: TestPassword123!
Role: ADMIN
Permissions: Full system access
```
**Use this account to:**
- Access admin-only features
- Manage users and system settings
- View all animals and trades
- Test administrative workflows

---

### **🟡 HR Manager Account**
```
Email: hr@zauro.com
Password: TestPassword123!
Role: HR_MANAGER
Permissions: Manage employees and trades
```
**Use this account to:**
- Manage employee trader accounts
- Oversee trading operations
- Access HR-specific features
- Test manager-level permissions

---

### **🟢 Active Trader Account #1**
```
Email: trader1@zauro.com
Password: TestPassword123!
Role: EMPLOYEE_TRADER
Status: Verified & Active
Animals: Buddy (Dog), Whiskers (Cat), Charlie (Dog)
Wallet: 0.0.100003
```
**Use this account to:**
- List animals for sale
- Browse marketplace
- Execute trades as seller
- Test verified user features

---

### **🟢 Active Trader Account #2**
```
Email: trader2@zauro.com
Password: TestPassword123!
Role: EMPLOYEE_TRADER
Status: Verified & Active
Animals: Bella (Dog), Mittens (Cat), Rainbow (Bird)
Wallet: 0.0.100004
```
**Use this account to:**
- Purchase animals from marketplace
- Execute trades as buyer
- Test cross-user trading
- Manage diverse animal portfolio

---

### **🔵 Regular User Account**
```
Email: user@zauro.com
Password: TestPassword123!
Role: EMPLOYEE_TRADER
Status: UNVERIFIED (for testing verification flow)
Animals: Nemo (Fish)
Wallet: 0.0.100005
```
**Use this account to:**
- Test user registration flow
- Test email/phone verification
- Test unverified user limitations
- Test account activation process

---

## 🐾 **Sample Animals Available for Testing**

### **Trader 1's Animals**
| Animal | Species | Breed | Age | Status | Price | AI Score |
|--------|---------|-------|-----|--------|-------|----------|
| **Buddy** | Dog | Golden Retriever | 3 | **FOR SALE** | 1,500 HBAR | 85.5 |
| **Whiskers** | Cat | Persian | 2 | Not Listed | - | 92.3 |
| **Charlie** | Dog | Labrador | 4 | **FOR SALE** | 2,000 HBAR | 88.7 |

### **Trader 2's Animals**
| Animal | Species | Breed | Age | Status | Price | AI Score |
|--------|---------|-------|-----|--------|-------|----------|
| **Bella** | Dog | German Shepherd | 5 | **FOR SALE** | 2,500 HBAR | 94.1 |
| **Mittens** | Cat | Maine Coon | 1 | Not Listed | - | 76.8 |
| **Rainbow** | Bird | Macaw | 7 | **FOR SALE** | 3,000 HBAR | 89.2 |

### **Other Animals**
| Owner | Animal | Species | Breed | Status | Price |
|-------|--------|---------|-------|--------|-------|
| Admin | **Rex** | Dog | Rottweiler | Not Listed | - |
| User | **Nemo** | Fish | Clownfish | **FOR SALE** | 500 HBAR |

---

## 💼 **Sample Trades for Testing**

| Trade ID | Animal | Seller | Buyer | Price | Status |
|----------|--------|--------|-------|-------|--------|
| 1 | Buddy | trader1 | - | 1,500 HBAR | **LISTED** |
| 2 | Charlie | trader1 | trader2 | 2,000 HBAR | **PENDING** |
| 3 | Bella | trader2 | - | 2,500 HBAR | **LISTED** |
| 4 | Rainbow | trader2 | - | 3,000 HBAR | **LISTED** |
| 5 | Nemo | user | - | 500 HBAR | **LISTED** |
| 6 | (Historical) | admin | trader1 | 1,800 HBAR | **COMPLETED** |

---

## 🧪 **Complete Testing Scenarios**

### **🔐 Authentication Testing**

#### **Scenario 1: Login Flow**
1. **Test successful login:**
   - Use: `trader1@zauro.com` / `TestPassword123!`
   - Expected: Successful login with JWT tokens
   - Verify: User dashboard loads with animals

2. **Test failed login:**
   - Use: `trader1@zauro.com` / `WrongPassword`
   - Expected: Error message "Invalid credentials"

3. **Test unverified user:**
   - Use: `user@zauro.com` / `TestPassword123!`
   - Expected: Login success but limited features

#### **Scenario 2: Password Recovery**
1. **Request password reset:**
   - Use email: `user@zauro.com`
   - Expected: OTP sent (check logs)
   - Test OTP: `123456` (pre-seeded)

2. **Verify OTP and reset password:**
   - Use OTP: `123456`
   - Set new password: `NewPassword123!`
   - Expected: Password successfully reset

---

### **🐾 Animal Management Testing**

#### **Scenario 3: View Animals**
1. **Login as trader1:**
   - Expected: See 3 animals (Buddy, Whiskers, Charlie)
   - Verify: Animal details, images, NFT info

2. **View animal details:**
   - Click on "Buddy"
   - Expected: Full animal profile with NFT token info
   - Verify: AI prediction score (85.5)

#### **Scenario 4: Add New Animal**
1. **Login as trader2:**
   - Navigate to "Add Animal"
   - Fill form with new animal data
   - Expected: Animal created with NFT minting

2. **Upload animal image:**
   - Select image file
   - Expected: Image uploaded to Supabase
   - Verify: Image URL stored in database

---

### **💰 Trading & Marketplace Testing**

#### **Scenario 5: Browse Marketplace**
1. **Login as any trader:**
   - Navigate to marketplace
   - Expected: See 5 listed animals
   - Verify: Prices, seller info, animal details

2. **Filter marketplace:**
   - Filter by species: "Dog"
   - Expected: Show Buddy, Charlie, Bella
   - Filter by price range
   - Expected: Results filtered correctly

#### **Scenario 6: Execute Trade**
1. **Login as trader2:**
   - Find "Buddy" (listed by trader1)
   - Click "Buy Now" for 1,500 HBAR
   - Expected: Trade initiated

2. **Complete purchase:**
   - Confirm transaction
   - Expected: NFT transferred, payment processed
   - Verify: Buddy now owned by trader2

#### **Scenario 7: List Animal for Sale**
1. **Login as trader1:**
   - Select "Whiskers" (not listed)
   - Click "List for Sale"
   - Set price: 1,200 HBAR
   - Expected: Animal appears in marketplace

---

### **💳 Wallet Testing**

#### **Scenario 8: View Wallet**
1. **Login as any trader:**
   - Navigate to wallet section
   - Expected: Hedera account ID displayed
   - Verify: Account balance shown

2. **View transaction history:**
   - Expected: Past transactions listed
   - Verify: Trade completions recorded

#### **Scenario 9: Create Wallet**
1. **Create new user account:**
   - Register new user
   - Expected: Wallet automatically created
   - Verify: Hedera account generated

---

### **👤 User Management Testing**

#### **Scenario 10: Admin Functions**
1. **Login as admin:**
   - View all users
   - Expected: See all 5 test accounts
   - Verify: User roles and statuses

2. **Manage user permissions:**
   - Update user role
   - Expected: Permissions changed
   - Verify: Access level updated

#### **Scenario 11: Profile Management**
1. **Login as any user:**
   - Navigate to profile
   - Update personal information
   - Expected: Changes saved successfully

---

## 🔍 **API Testing with Swagger**

### **Access Swagger Documentation**
```
URL: http://localhost:3000/api/docs
```

### **Authentication for API Testing**
1. **Get JWT token:**
   ```bash
   POST /api/v1/auth/login
   {
     "email": "trader1@zauro.com",
     "password": "TestPassword123!"
   }
   ```

2. **Use token in Swagger:**
   - Click "Authorize" button
   - Enter: `Bearer YOUR_JWT_TOKEN`
   - All authenticated endpoints now accessible

### **Key API Endpoints to Test**
```bash
# Authentication
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/forgot-password/request

# Animals
GET  /api/v1/animals          # List animals
POST /api/v1/animals          # Create animal
GET  /api/v1/animals/{id}     # Get animal details
PATCH /api/v1/animals/{id}    # Update animal

# Trading
GET  /api/v1/trades           # List trades
POST /api/v1/trades/list      # List animal for sale
POST /api/v1/trades/buy/{id}  # Buy animal

# Wallet
POST /api/v1/wallets/create   # Create wallet
GET  /api/v1/wallets/my-wallet # Get my wallet
GET  /api/v1/wallets/my-wallet/balance # Get balance
```

---

## 📱 **Flutter App Testing**

### **Configure Flutter App**
1. **Update API URL in Flutter:**
   ```dart
   // frontend/lib/core/config/app_config.dart
   static const String baseUrl = 'http://localhost:3000'; // or your IP
   ```

2. **Run Flutter app:**
   ```bash
   cd frontend
   flutter pub get
   flutter packages pub run build_runner build
   flutter run
   ```

### **Test with Pre-configured Accounts**
Use the same test accounts listed above in the Flutter app:
- Login with `trader1@zauro.com` / `TestPassword123!`
- Browse animals and marketplace
- Test trading functionality
- Verify wallet integration

---

## 🐛 **Troubleshooting**

### **Common Issues & Solutions**

#### **Database Connection Error**
```bash
# Check PostgreSQL is running
# Verify DATABASE_URL in .env file
# Run migrations if needed:
npx prisma migrate dev
```

#### **Seeding Fails**
```bash
# Clear database and reseed:
npx prisma migrate reset
npm run db:seed
```

#### **JWT Token Issues**
```bash
# Check JWT_SECRET and JWT_REFRESH_SECRET in .env
# Tokens expire after 15 minutes - get new token if needed
```

#### **Hedera Connection Issues**
```bash
# Verify HEDERA_ACCOUNT_ID and HEDERA_PRIVATE_KEY in .env
# Check HEDERA_NETWORK is set to "testnet"
# Ensure account has sufficient HBAR balance
```

---

## 🎯 **Testing Checklist**

### **✅ Authentication**
- [ ] User registration
- [ ] User login/logout
- [ ] Password recovery
- [ ] JWT token refresh
- [ ] Role-based access control

### **✅ Animal Management**
- [ ] View animal list
- [ ] View animal details
- [ ] Add new animal
- [ ] Upload animal images
- [ ] Update animal information
- [ ] NFT minting integration

### **✅ Trading System**
- [ ] Browse marketplace
- [ ] List animal for sale
- [ ] Purchase animal
- [ ] Trade status updates
- [ ] Transaction history
- [ ] Price filtering

### **✅ Wallet Integration**
- [ ] Create Hedera wallet
- [ ] View wallet balance
- [ ] Transaction history
- [ ] HBAR transfers
- [ ] Private key encryption

### **✅ User Interface**
- [ ] Responsive design
- [ ] Loading states
- [ ] Error handling
- [ ] Form validation
- [ ] Navigation flow

### **✅ API Integration**
- [ ] All endpoints functional
- [ ] Proper error responses
- [ ] Authentication middleware
- [ ] Rate limiting
- [ ] Swagger documentation

---

## 📊 **Performance Testing**

### **Load Testing Scenarios**
1. **Concurrent logins:** 10 users login simultaneously
2. **Marketplace browsing:** Multiple users browse animals
3. **Trading volume:** Execute multiple trades concurrently
4. **Image uploads:** Upload multiple animal images

### **Expected Performance**
- **API Response Time:** < 500ms for most endpoints
- **Database Queries:** < 100ms average
- **File Uploads:** < 2s for 5MB images
- **Hedera Transactions:** < 10s for NFT operations

---

## 🔐 **Security Testing**

### **Test Security Features**
- [ ] Password hashing (bcrypt)
- [ ] JWT token validation
- [ ] Private key encryption
- [ ] Rate limiting
- [ ] Input validation
- [ ] CORS configuration
- [ ] SQL injection prevention

---

## 🎉 **Ready to Test!**

You now have **everything needed** to thoroughly test the Zauro Marketplace:

1. **✅ 5 Pre-configured test accounts** with different roles
2. **✅ 8 Sample animals** with realistic data and NFT tokens
3. **✅ 6 Sample trades** in different states
4. **✅ Complete testing scenarios** covering all features
5. **✅ API documentation** with Swagger integration
6. **✅ Flutter app integration** ready to test

### **Start Testing Now:**
```bash
# 1. Seed the database
npm run db:seed

# 2. Start the backend
npm run start:dev

# 3. Login with: trader1@zauro.com / TestPassword123!

# 4. Start testing! 🚀
```

**Happy Testing! 🧪✨**
