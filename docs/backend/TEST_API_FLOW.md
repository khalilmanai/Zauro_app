# Complete System Flow Test

## Overview
Test the complete flow from user registration to animal trading.

## Prerequisites

1. **Run Database Migration**:
```bash
npx prisma generate
npx prisma migrate dev --name add_expert_review_system
```

2. **Start Services**:
```bash
docker compose up -d
```

3. **Wait for services to be healthy**:
```bash
# Check services
curl http://localhost:5000/health  # Animal Detection
curl http://localhost:3000/api/v1  # Backend
```

## Test Flow

### Step 1: User Registration

```bash
# Register a regular user
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "EMPLOYEE_TRADER"
  }'

# Expected: 201 Created with user data
# Save the response token for next steps
```

### Step 2: Register an Expert (Admin)

```bash
# Register an admin/expert
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "expert@example.com",
    "password": "SecurePass123!",
    "firstName": "Dr. Jane",
    "lastName": "Smith",
    "role": "ADMIN"
  }'

# Expected: 201 Created with user data
# Save the expert token for review steps
```

### Step 3: Create Animal (with AI Analysis)

```bash
# Create animal with image - will get PENDING_EXPERT_REVIEW status
curl -X POST http://localhost:3000/api/v1/animals \
  -H "Authorization: Bearer USER_TOKEN" \
  -F "name=Bella" \
  -F "species=COW" \
  -F "gender=FEMALE" \
  -F "image=@animal detection/download (1).jpg"

# Expected: 201 Created
# Response includes: status: PENDING_EXPERT_REVIEW, aiPredictionValue: <number>
# Save the animal ID
```

### Step 4: View Pending Animals (Expert)

```bash
# Expert views pending animals
curl http://localhost:3000/api/v1/animals/pending-review \
  -H "Authorization: Bearer EXPERT_TOKEN"

# Expected: 200 OK
# Response: List of animals with status PENDING_EXPERT_REVIEW
```

### Step 5: Expert Reviews and Approves

```bash
# Expert approves the animal
curl -X PUT http://localhost:3000/api/v1/animals/ANIMAL_ID/review \
  -H "Authorization: Bearer EXPERT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "approved": true,
    "comment": "Healthy animal, excellent breed"
  }'

# Expected: 200 OK
# Response: status: EXPERT_APPROVED, expertReviewedBy, expertReviewDate
```

### Step 6: User Mints NFT

```bash
# User mints NFT after approval
curl -X POST http://localhost:3000/api/v1/animals/ANIMAL_ID/mint \
  -H "Authorization: Bearer USER_TOKEN"

# Expected: 201 Created
# Response: status: MINTED, tokenId, tokenSerialNumber
```

### Step 7: List Animal for Trade

```bash
# List animal for trade
curl -X POST http://localhost:3000/api/v1/trades/list \
  -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "animalId": "ANIMAL_ID",
    "price": 5000,
    "currency": "HBAR"
  }'

# Expected: 201 Created
# Response: Trade details with status: LISTED
```

### Step 8: Buyer Views Available Animals

```bash
# Get all available animals for trade
curl http://localhost:3000/api/v1/animals?isListed=true

# Expected: 200 OK
# Response: List of animals that are listed for trade
```

### Step 9: Buy Animal

```bash
# Buy an animal
curl -X POST http://localhost:3000/api/v1/trades/buy/TRADE_ID \
  -H "Authorization: Bearer BUYER_TOKEN" \
  -H "Content-Type: application/json"

# Expected: 200 OK
# Response: Trade status: IN_PROGRESS
```

## Expected Results

### User Flow
1. ✅ User registers
2. ✅ User creates animal → Status: `PENDING_EXPERT_REVIEW`
3. ✅ AI analysis runs automatically
4. ✅ Animal awaits expert review
5. ✅ Expert approves → Status: `EXPERT_APPROVED`
6. ✅ User mints NFT → Status: `MINTED`
7. ✅ User lists for trade → Status: `LISTED`
8. ✅ Buyer purchases → Trade: `COMPLETED`

### Database States

**Animals Table**:
- Initial: `status = PENDING_EXPERT_REVIEW`
- After Review: `status = EXPERT_APPROVED/REJECTED`
- After Mint: `status = MINTED`, `tokenId`, `tokenSerialNumber` populated
- After List: `isListed = true`

**Trades Table**:
- After List: `status = LISTED`
- After Buy: `status = IN_PROGRESS`
- After Complete: `status = COMPLETED`

## Quick Test Script

```bash
# Test all endpoints quickly
API_URL="http://localhost:3000/api/v1"
ADMIN_TOKEN="your-admin-token"
USER_TOKEN="your-user-token"

# Test health
echo "Testing health..."
curl -s $API_URL

# Test pending reviews
echo "Testing pending reviews..."
curl -s "$API_URL/animals/pending-review" -H "Authorization: Bearer $ADMIN_TOKEN"

# Test animal creation
echo "Testing animal creation..."
curl -s -X POST "$API_URL/animals" \
  -H "Authorization: Bearer $USER_TOKEN" \
  -F "name=Test Cow" \
  -F "species=COW" \
  -F "gender=FEMALE" \
  -F "image=@animal detection/download (1).jpg"
```

## Troubleshooting

### Animal Detection Service Not Available
```bash
# Check logs
docker logs zauro_animal_detection

# Restart if needed
docker compose restart animal-detection
```

### Database Migration Issues
```bash
# Reset database
npx prisma migrate reset

# Re-run migration
npx prisma migrate dev
```

### NFT Minting Fails
- Check wallet exists
- Verify Hedera credentials
- Check animal status is `EXPERT_APPROVED`

## Success Criteria

✅ All services running  
✅ User can register  
✅ Animal created with AI analysis  
✅ Status is `PENDING_EXPERT_REVIEW`  
✅ Expert can view pending animals  
✅ Expert can approve/reject  
✅ NFT mints successfully  
✅ Animal can be listed for trade  
✅ Trading works end-to-end  

## Notes

- Animal images are in `animal detection/` folder
- AI analysis automatically detects breed, age, sex, health
- Expert review is required before minting
- Trading requires minted NFT
- All endpoints require authentication (JWT token)

