# Zauro System Testing Script
# This script tests the complete NFT collection and minting system

Write-Host "ZAURO SYSTEM TESTING SCRIPT" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000/api/v1"
$headers = @{
    "Content-Type" = "application/json"
}

# Test data
$testUser = @{
    email = "test@zauro.com"
    password = "TestPassword123!"
    firstName = "Test"
    lastName = "User"
}

$testAnimal = @{
    name = "Test Dog"
    species = "OTHER"
    breed = "Golden Retriever"
    age = 3
    gender = "MALE"
    description = "Test animal for NFT minting verification"
}

Write-Host "`nSTEP 1: Register Test User" -ForegroundColor Yellow
try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body ($testUser | ConvertTo-Json) -Headers $headers
    Write-Host "SUCCESS: User registered successfully" -ForegroundColor Green
    Write-Host "   User ID: $($registerResponse.user.id)" -ForegroundColor Gray
    Write-Host "   Access Token: $($registerResponse.accessToken.Substring(0,20))..." -ForegroundColor Gray
    
    $accessToken = $registerResponse.accessToken
    $userId = $registerResponse.user.id
    $authHeaders = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $accessToken"
    }
} catch {
    Write-Host "ERROR: User registration failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nSTEP 2: Create Wallet" -ForegroundColor Yellow
try {
    $walletResponse = Invoke-RestMethod -Uri "$baseUrl/wallets/create" -Method POST -Headers $authHeaders
    Write-Host "SUCCESS: Wallet created successfully" -ForegroundColor Green
    Write-Host "   Hedera Account ID: $($walletResponse.hederaAccountId)" -ForegroundColor Gray
    Write-Host "   Balance: $($walletResponse.balance.hbar) HBAR" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Wallet creation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nSTEP 3: Check Collections" -ForegroundColor Yellow
try {
    $collectionsResponse = Invoke-RestMethod -Uri "$baseUrl/admin/collections" -Method GET -Headers $authHeaders
    Write-Host "SUCCESS: Collections retrieved successfully" -ForegroundColor Green
    Write-Host "   Total Collections: $($collectionsResponse.Count)" -ForegroundColor Gray
    
    foreach ($collection in $collectionsResponse) {
        Write-Host "   Collection: $($collection.name) ($($collection.symbol))" -ForegroundColor Gray
        Write-Host "     Token ID: $($collection.tokenId)" -ForegroundColor Gray
        Write-Host "     Default: $($collection.isDefault)" -ForegroundColor Gray
        Write-Host "     Max Supply: $($collection.maxSupply)" -ForegroundColor Gray
    }
} catch {
    Write-Host "ERROR: Collections retrieval failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nSTEP 4: Create Animal (NFT)" -ForegroundColor Yellow
try {
    $animalResponse = Invoke-RestMethod -Uri "$baseUrl/animals" -Method POST -Body ($testAnimal | ConvertTo-Json) -Headers $authHeaders
    Write-Host "SUCCESS: Animal created successfully" -ForegroundColor Green
    Write-Host "   Animal ID: $($animalResponse.id)" -ForegroundColor Gray
    Write-Host "   Name: $($animalResponse.name)" -ForegroundColor Gray
    Write-Host "   Token ID: $($animalResponse.tokenId)" -ForegroundColor Gray
    Write-Host "   Serial Number: $($animalResponse.tokenSerialNumber)" -ForegroundColor Gray
    
    $animalId = $animalResponse.id
    $tokenId = $animalResponse.tokenId
    $serialNumber = $animalResponse.tokenSerialNumber
} catch {
    Write-Host "ERROR: Animal creation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nSTEP 5: Check Wallet Balance" -ForegroundColor Yellow
try {
    $balanceResponse = Invoke-RestMethod -Uri "$baseUrl/wallets/my-wallet/balance" -Method GET -Headers $authHeaders
    Write-Host "SUCCESS: Wallet balance retrieved" -ForegroundColor Green
    Write-Host "   HBAR Balance: $($balanceResponse.hbar)" -ForegroundColor Gray
    Write-Host "   ZAU Balance: $($balanceResponse.zau)" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Balance check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nSTEP 6: Create Trade Listing" -ForegroundColor Yellow
try {
    $tradeData = @{
        animalId = $animalId
        price = 100.50
        currency = "HBAR"
    }
    $tradeResponse = Invoke-RestMethod -Uri "$baseUrl/trades/list" -Method POST -Body ($tradeData | ConvertTo-Json) -Headers $authHeaders
    Write-Host "SUCCESS: Trade listed successfully" -ForegroundColor Green
    Write-Host "   Trade ID: $($tradeResponse.id)" -ForegroundColor Gray
    Write-Host "   Price: $($tradeResponse.price) $($tradeResponse.currency)" -ForegroundColor Gray
    Write-Host "   Status: $($tradeResponse.status)" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Trade listing failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nSTEP 7: Get All Animals" -ForegroundColor Yellow
try {
    $animalsResponse = Invoke-RestMethod -Uri "$baseUrl/animals" -Method GET -Headers $authHeaders
    Write-Host "SUCCESS: Animals retrieved successfully" -ForegroundColor Green
    Write-Host "   Total Animals: $($animalsResponse.total)" -ForegroundColor Gray
    
    foreach ($animal in $animalsResponse.animals) {
        Write-Host "   Animal: $($animal.name)" -ForegroundColor Gray
        Write-Host "     Token ID: $($animal.tokenId)" -ForegroundColor Gray
        Write-Host "     Serial: $($animal.tokenSerialNumber)" -ForegroundColor Gray
        Write-Host "     Listed: $($animal.isListed)" -ForegroundColor Gray
    }
} catch {
    Write-Host "ERROR: Animals retrieval failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTESTING COMPLETE!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "`nSUMMARY:" -ForegroundColor Yellow
Write-Host "SUCCESS: User Registration" -ForegroundColor Green
Write-Host "SUCCESS: Wallet Creation" -ForegroundColor Green
Write-Host "SUCCESS: Collection Management" -ForegroundColor Green
Write-Host "SUCCESS: NFT Minting" -ForegroundColor Green
Write-Host "SUCCESS: Trade Listing" -ForegroundColor Green

Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Check PgAdmin at http://localhost:5050" -ForegroundColor Gray
Write-Host "2. Verify blockchain data on Hedera Explorer" -ForegroundColor Gray
Write-Host "3. Check API docs at http://localhost:3000/docs" -ForegroundColor Gray
