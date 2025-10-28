# Swagger API Examples - Zauro Marketplace

This document provides sample data for testing the Zauro Marketplace API endpoints through Swagger UI.

## 🚀 Getting Started

1. Start the development server: `npm run start:dev`
2. Open Swagger UI: http://localhost:3000/api/docs
3. Use the examples below to test the API endpoints

## 📋 Sample Data for Testing

### 1. User Registration

**POST /auth/register**
```json
{
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "password": "SecurePassword123!",
  "firstName": "John",
  "lastName": "Doe"
}
```

### 2. User Login

**POST /auth/login**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePassword123!"
}
```

### 3. Forgot Password Request

**POST /auth/forgot-password/request**
```json
{
  "email": "john.doe@example.com"
}
```

### 4. Verify OTP

**POST /auth/forgot-password/verify**
```json
{
  "code": "123456",
  "email": "john.doe@example.com"
}
```

### 5. Reset Password

**POST /auth/forgot-password/reset**
```json
{
  "code": "123456",
  "newPassword": "NewSecurePassword123!",
  "email": "john.doe@example.com"
}
```

### 6. Create Animal

**POST /animals**
```json
{
  "name": "Buddy",
  "species": "DOG",
  "breed": "Golden Retriever",
  "age": 3,
  "description": "Friendly and energetic dog, great with children and other pets. Fully house trained and loves outdoor activities.",
  "aiPredictionValue": 1500.50
}
```

### 7. Update Animal

**PATCH /animals/{id}**
```json
{
  "name": "Buddy Jr.",
  "description": "Updated description: Very friendly dog, now even more energetic!",
  "aiPredictionValue": 1600.00
}
```

### 8. Create Trade

**POST /trades/list**
```json
{
  "animalId": "cm4abc123def456ghi789jkl",
  "price": 100.50,
  "currency": "HBAR"
}
```

### 9. Pagination Parameters

For endpoints that support pagination (GET /animals, GET /trades):
```
page: 1
limit: 10
```

## 🎯 Available Animal Species

When creating or updating animals, use one of these species values:
- `DOG`
- `CAT`
- `BIRD`
- `FISH`
- `REPTILE`
- `OTHER`

## 💰 Supported Currencies

For trade creation:
- `HBAR` (default)
- `ZAU`

## 🔐 Authentication

Most endpoints require authentication. After logging in:
1. Copy the `accessToken` from the login response
2. Click the "Authorize" button in Swagger UI
3. Enter: `Bearer YOUR_ACCESS_TOKEN`
4. Click "Authorize"

## 📝 Notes

- All examples are pre-populated in the Swagger UI
- Animal IDs and User IDs follow CUID format (e.g., `cm4abc123def456ghi789jkl`)
- Phone numbers should include country code (e.g., `+1234567890`)
- Passwords must be at least 8 characters long
- Ages must be between 0 and 50 years
- Prices must be positive numbers

## 🧪 Testing Workflow

1. **Register** a new user
2. **Login** with the registered user
3. **Create wallet** for the user
4. **Create animal** and mint NFT
5. **List animal** for trade
6. **Browse trades** and test buying functionality

Happy testing! 🚀
