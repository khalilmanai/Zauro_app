-- Zauro Database Verification Queries
-- Run these in PgAdmin or psql to verify data integrity

-- 1. Check all users
SELECT 
    id, 
    email, 
    "firstName", 
    "lastName", 
    role, 
    "isVerified", 
    "isActive",
    "createdAt"
FROM users 
ORDER BY "createdAt" DESC;

-- 2. Check all wallets
SELECT 
    w.id,
    w."hederaAccountId",
    w."publicKey",
    w."createdAt",
    u.email as user_email
FROM wallets w
JOIN users u ON w."userId" = u.id
ORDER BY w."createdAt" DESC;

-- 3. Check all collections
SELECT 
    id,
    name,
    symbol,
    "tokenId",
    "isDefault",
    status,
    "maxSupply",
    "autoRotate",
    "createdAt"
FROM collections
ORDER BY "createdAt" DESC;

-- 4. Check all animals (NFTs)
SELECT 
    a.id,
    a.name,
    a.species,
    a.breed,
    a.age,
    a.gender,
    a."tokenId",
    a."tokenSerialNumber",
    a."isListed",
    a."createdAt",
    u.email as owner_email
FROM animals a
JOIN users u ON a."ownerId" = u.id
ORDER BY a."createdAt" DESC;

-- 5. Check all trades
SELECT 
    t.id,
    t.price,
    t.currency,
    t.status,
    t."transactionHash",
    t."createdAt",
    t."completedAt",
    a.name as animal_name,
    seller.email as seller_email,
    buyer.email as buyer_email
FROM trades t
JOIN animals a ON t."animalId" = a.id
JOIN users seller ON t."sellerId" = seller.id
LEFT JOIN users buyer ON t."buyerId" = buyer.id
ORDER BY t."createdAt" DESC;

-- 6. Check file uploads
SELECT 
    id,
    "fileName",
    "originalName",
    "mimeType",
    size,
    url,
    "uploadedBy",
    "createdAt"
FROM file_uploads
ORDER BY "createdAt" DESC;

-- 7. Check OTPs
SELECT 
    id,
    "userId",
    code,
    type,
    "isUsed",
    "expiresAt",
    "createdAt",
    "usedAt"
FROM otps
ORDER BY "createdAt" DESC;

-- 8. Summary statistics
SELECT 
    'Users' as table_name,
    COUNT(*) as total_count
FROM users
UNION ALL
SELECT 
    'Wallets' as table_name,
    COUNT(*) as total_count
FROM wallets
UNION ALL
SELECT 
    'Collections' as table_name,
    COUNT(*) as total_count
FROM collections
UNION ALL
SELECT 
    'Animals' as table_name,
    COUNT(*) as total_count
FROM animals
UNION ALL
SELECT 
    'Trades' as table_name,
    COUNT(*) as total_count
FROM trades
UNION ALL
SELECT 
    'File Uploads' as table_name,
    COUNT(*) as total_count
FROM file_uploads
UNION ALL
SELECT 
    'OTPs' as table_name,
    COUNT(*) as total_count
FROM otps;

-- 9. Check NFT token distribution
SELECT 
    c.name as collection_name,
    c."tokenId",
    COUNT(a.id) as nft_count,
    c."maxSupply",
    CASE 
        WHEN c."maxSupply" IS NULL THEN 'Infinite'
        ELSE CONCAT(ROUND((COUNT(a.id)::float / c."maxSupply"::float) * 100, 2), '%')
    END as usage_percentage
FROM collections c
LEFT JOIN animals a ON c."tokenId" = a."tokenId"
GROUP BY c.id, c.name, c."tokenId", c."maxSupply"
ORDER BY nft_count DESC;

-- 10. Check wallet balances (if you have balance tracking)
-- This would require additional queries to Hedera network
-- SELECT 
--     w."hederaAccountId",
--     u.email,
--     -- Add balance fields if you store them locally
-- FROM wallets w
-- JOIN users u ON w."userId" = u.id;
