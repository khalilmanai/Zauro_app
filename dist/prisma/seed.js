"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Starting database seeding...');
    if (process.env.NODE_ENV === 'development') {
        console.log('🧹 Cleaning existing data...');
        await prisma.trade.deleteMany();
        await prisma.animal.deleteMany();
        await prisma.wallet.deleteMany();
        await prisma.otp.deleteMany();
        await prisma.user.deleteMany();
    }
    console.log('👥 Creating test users...');
    const hashedPassword = await bcrypt.hash('TestPassword123!', 12);
    const adminUser = await prisma.user.create({
        data: {
            email: 'admin@zauro.com',
            phone: '+1234567890',
            password: hashedPassword,
            firstName: 'Admin',
            lastName: 'User',
            role: client_1.UserRole.ADMIN,
            isVerified: true,
            isActive: true,
        },
    });
    const hrUser = await prisma.user.create({
        data: {
            email: 'hr@zauro.com',
            phone: '+1234567891',
            password: hashedPassword,
            firstName: 'HR',
            lastName: 'Manager',
            role: client_1.UserRole.HR_MANAGER,
            isVerified: true,
            isActive: true,
        },
    });
    const trader1 = await prisma.user.create({
        data: {
            email: 'trader1@zauro.com',
            phone: '+1234567892',
            password: hashedPassword,
            firstName: 'John',
            lastName: 'Trader',
            role: client_1.UserRole.EMPLOYEE_TRADER,
            isVerified: true,
            isActive: true,
        },
    });
    const trader2 = await prisma.user.create({
        data: {
            email: 'trader2@zauro.com',
            phone: '+1234567893',
            password: hashedPassword,
            firstName: 'Jane',
            lastName: 'Smith',
            role: client_1.UserRole.EMPLOYEE_TRADER,
            isVerified: true,
            isActive: true,
        },
    });
    const regularUser = await prisma.user.create({
        data: {
            email: 'user@zauro.com',
            phone: '+1234567894',
            password: hashedPassword,
            firstName: 'Test',
            lastName: 'User',
            role: client_1.UserRole.EMPLOYEE_TRADER,
            isVerified: false,
            isActive: true,
        },
    });
    console.log('✅ Created test users');
    console.log('💰 Creating test wallets...');
    const testWallets = [
        {
            userId: adminUser.id,
            hederaAccountId: '0.0.100001',
            publicKey: '302a300506032b6570032100' + 'a'.repeat(64),
            encryptedPrivateKey: 'encrypted_admin_private_key_' + Math.random().toString(36),
        },
        {
            userId: hrUser.id,
            hederaAccountId: '0.0.100002',
            publicKey: '302a300506032b6570032100' + 'b'.repeat(64),
            encryptedPrivateKey: 'encrypted_hr_private_key_' + Math.random().toString(36),
        },
        {
            userId: trader1.id,
            hederaAccountId: '0.0.100003',
            publicKey: '302a300506032b6570032100' + 'c'.repeat(64),
            encryptedPrivateKey: 'encrypted_trader1_private_key_' + Math.random().toString(36),
        },
        {
            userId: trader2.id,
            hederaAccountId: '0.0.100004',
            publicKey: '302a300506032b6570032100' + 'd'.repeat(64),
            encryptedPrivateKey: 'encrypted_trader2_private_key_' + Math.random().toString(36),
        },
        {
            userId: regularUser.id,
            hederaAccountId: '0.0.100005',
            publicKey: '302a300506032b6570032100' + 'e'.repeat(64),
            encryptedPrivateKey: 'encrypted_user_private_key_' + Math.random().toString(36),
        },
    ];
    for (const walletData of testWallets) {
        await prisma.wallet.create({ data: walletData });
    }
    console.log('✅ Created test wallets');
    console.log('🐾 Creating sample animals...');
    const sampleAnimals = [
        {
            name: 'Buddy',
            species: client_1.AnimalSpecies.DOG,
            breed: 'Golden Retriever',
            age: 3,
            description: 'Friendly and energetic golden retriever. Great with kids and other pets.',
            ownerId: trader1.id,
            tokenId: '0.0.200001',
            tokenSerialNumber: '1',
            imageUrl: 'https://example.com/images/buddy.jpg',
            vetRecordUrl: 'https://example.com/vet-records/buddy.pdf',
            aiPredictionValue: 85.5,
            isListed: true,
        },
        {
            name: 'Whiskers',
            species: client_1.AnimalSpecies.CAT,
            breed: 'Persian',
            age: 2,
            description: 'Beautiful Persian cat with long, silky fur. Very calm and affectionate.',
            ownerId: trader1.id,
            tokenId: '0.0.200002',
            tokenSerialNumber: '2',
            imageUrl: 'https://example.com/images/whiskers.jpg',
            vetRecordUrl: 'https://example.com/vet-records/whiskers.pdf',
            aiPredictionValue: 92.3,
            isListed: false,
        },
        {
            name: 'Charlie',
            species: client_1.AnimalSpecies.DOG,
            breed: 'Labrador',
            age: 4,
            description: 'Loyal Labrador with excellent training. Perfect family companion.',
            ownerId: trader1.id,
            tokenId: '0.0.200003',
            tokenSerialNumber: '3',
            imageUrl: 'https://example.com/images/charlie.jpg',
            vetRecordUrl: 'https://example.com/vet-records/charlie.pdf',
            aiPredictionValue: 88.7,
            isListed: true,
        },
        {
            name: 'Bella',
            species: client_1.AnimalSpecies.DOG,
            breed: 'German Shepherd',
            age: 5,
            description: 'Intelligent German Shepherd with guard training. Very protective and loyal.',
            ownerId: trader2.id,
            tokenId: '0.0.200004',
            tokenSerialNumber: '4',
            imageUrl: 'https://example.com/images/bella.jpg',
            vetRecordUrl: 'https://example.com/vet-records/bella.pdf',
            aiPredictionValue: 94.1,
            isListed: true,
        },
        {
            name: 'Mittens',
            species: client_1.AnimalSpecies.CAT,
            breed: 'Maine Coon',
            age: 1,
            description: 'Playful Maine Coon kitten. Very social and loves attention.',
            ownerId: trader2.id,
            tokenId: '0.0.200005',
            tokenSerialNumber: '5',
            imageUrl: 'https://example.com/images/mittens.jpg',
            vetRecordUrl: 'https://example.com/vet-records/mittens.pdf',
            aiPredictionValue: 76.8,
            isListed: false,
        },
        {
            name: 'Rainbow',
            species: client_1.AnimalSpecies.BIRD,
            breed: 'Macaw',
            age: 7,
            description: 'Colorful Macaw with excellent vocabulary. Can speak over 50 words.',
            ownerId: trader2.id,
            tokenId: '0.0.200006',
            tokenSerialNumber: '6',
            imageUrl: 'https://example.com/images/rainbow.jpg',
            vetRecordUrl: 'https://example.com/vet-records/rainbow.pdf',
            aiPredictionValue: 89.2,
            isListed: true,
        },
        {
            name: 'Rex',
            species: client_1.AnimalSpecies.DOG,
            breed: 'Rottweiler',
            age: 6,
            description: 'Strong and loyal Rottweiler with excellent temperament.',
            ownerId: adminUser.id,
            tokenId: '0.0.200007',
            tokenSerialNumber: '7',
            imageUrl: 'https://example.com/images/rex.jpg',
            vetRecordUrl: 'https://example.com/vet-records/rex.pdf',
            aiPredictionValue: 91.5,
            isListed: false,
        },
        {
            name: 'Nemo',
            species: client_1.AnimalSpecies.FISH,
            breed: 'Clownfish',
            age: 1,
            description: 'Beautiful clownfish in excellent health. Great for aquarium enthusiasts.',
            ownerId: regularUser.id,
            tokenId: '0.0.200008',
            tokenSerialNumber: '8',
            imageUrl: 'https://example.com/images/nemo.jpg',
            vetRecordUrl: 'https://example.com/vet-records/nemo.pdf',
            aiPredictionValue: 82.4,
            isListed: true,
        },
    ];
    const createdAnimals = [];
    for (const animalData of sampleAnimals) {
        const animal = await prisma.animal.create({ data: animalData });
        createdAnimals.push(animal);
    }
    console.log('✅ Created sample animals');
    console.log('💼 Creating sample trades...');
    const listedAnimals = createdAnimals.filter(animal => animal.isListed);
    const sampleTrades = [
        {
            animalId: listedAnimals.find(a => a.name === 'Buddy')?.id,
            sellerId: trader1.id,
            price: 1500.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.LISTED,
        },
        {
            animalId: listedAnimals.find(a => a.name === 'Charlie')?.id,
            sellerId: trader1.id,
            buyerId: trader2.id,
            price: 2000.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.PENDING,
        },
        {
            animalId: listedAnimals.find(a => a.name === 'Bella')?.id,
            sellerId: trader2.id,
            price: 2500.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.LISTED,
        },
        {
            animalId: listedAnimals.find(a => a.name === 'Rainbow')?.id,
            sellerId: trader2.id,
            price: 3000.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.LISTED,
        },
        {
            animalId: listedAnimals.find(a => a.name === 'Nemo')?.id,
            sellerId: regularUser.id,
            price: 500.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.LISTED,
        },
        {
            animalId: createdAnimals[0].id,
            sellerId: adminUser.id,
            buyerId: trader1.id,
            price: 1800.00,
            currency: 'HBAR',
            status: client_1.TradeStatus.COMPLETED,
            completedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        },
    ];
    for (const tradeData of sampleTrades) {
        await prisma.trade.create({ data: tradeData });
    }
    console.log('✅ Created sample trades');
    console.log('🔐 Creating sample OTPs...');
    await prisma.otp.create({
        data: {
            userId: regularUser.id,
            code: '123456',
            type: 'EMAIL_VERIFICATION',
            expiresAt: new Date(Date.now() + 10 * 60 * 1000),
        },
    });
    console.log('✅ Created sample OTPs');
    console.log('🎉 Database seeding completed successfully!');
    console.log('\n📊 SEEDING SUMMARY:');
    console.log('==================');
    console.log(`👥 Users created: 5`);
    console.log(`💰 Wallets created: 5`);
    console.log(`🐾 Animals created: 8`);
    console.log(`💼 Trades created: 6`);
    console.log(`🔐 OTPs created: 1`);
    console.log('\n🔑 TEST ACCOUNTS:');
    console.log('================');
    console.log('Admin Account:');
    console.log('  Email: admin@zauro.com');
    console.log('  Password: TestPassword123!');
    console.log('  Role: ADMIN');
    console.log('');
    console.log('HR Manager Account:');
    console.log('  Email: hr@zauro.com');
    console.log('  Password: TestPassword123!');
    console.log('  Role: HR_MANAGER');
    console.log('');
    console.log('Trader Account 1:');
    console.log('  Email: trader1@zauro.com');
    console.log('  Password: TestPassword123!');
    console.log('  Role: EMPLOYEE_TRADER');
    console.log('  Animals: Buddy, Whiskers, Charlie');
    console.log('');
    console.log('Trader Account 2:');
    console.log('  Email: trader2@zauro.com');
    console.log('  Password: TestPassword123!');
    console.log('  Role: EMPLOYEE_TRADER');
    console.log('  Animals: Bella, Mittens, Rainbow');
    console.log('');
    console.log('Regular User Account:');
    console.log('  Email: user@zauro.com');
    console.log('  Password: TestPassword123!');
    console.log('  Role: EMPLOYEE_TRADER');
    console.log('  Status: Unverified (for testing verification)');
    console.log('  Animals: Nemo');
}
main()
    .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map