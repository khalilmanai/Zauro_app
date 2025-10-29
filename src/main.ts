import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);


// Enable CORS
const allowedOrigins = process.env.CORS_ORIGIN?.split(',') || [
  'http://localhost:3002',
];

// In production, allow all origins for Swagger UI and API testing
const isProduction = process.env.NODE_ENV === 'production';

app.enableCors({
  origin: isProduction ? true : (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
    // Allow requests with no origin (mobile apps, curl, Postman)
    if (!origin) return callback(null, true);
    
    // Check if origin is in allowed list
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    // Allow Railway and Vercel domains
    if (origin.includes('.railway.app') || origin.includes('.vercel.app')) {
      return callback(null, true);
    }
    
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
});

  // Set global API prefix
  app.setGlobalPrefix('api/v1');

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // Swagger documentation with JWT Bearer authentication
  const config = new DocumentBuilder()
    .setTitle('Zauro Marketplace API')
    .setDescription('Blockchain-based animal marketplace API built with NestJS, Hedera, and Supabase')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth', // This name here is important for matching up with @ApiBearerAuth() in your controller!
    )
    .addServer('http://localhost:3000', 'Development server')
    .addServer('https://zauro-backend-production.up.railway.app', 'Production server')
    .addTag('Authentication', 'User authentication and authorization endpoints')
    .addTag('Wallet', 'Hedera wallet management and HBAR transfers')
    .addTag('Animals', 'Animal NFT management and marketplace listings')
    .addTag('Trades', 'Trading and transaction management')
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  
  // Enhanced Swagger UI options
  SwaggerModule.setup('docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true, // Keep authorization after page refresh
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
      docExpansion: 'none', // Don't expand operations by default
      filter: true, // Enable search filter
      showRequestHeaders: true,
      tryItOutEnabled: true,
    },
    customSiteTitle: 'Zauro API Documentation',
    customfavIcon: '/favicon.ico',
    customJs: [
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-bundle.min.js',
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui-standalone-preset.min.js',
    ],
    customCssUrl: [
      'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/4.15.5/swagger-ui.min.css',
    ],
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 Zauro Backend is running on: http://localhost:${port}`);
  console.log(`📚 API Documentation: http://localhost:${port}/docs`);
  console.log(`🔗 API Base URL: http://localhost:${port}/api/v1`);
}
bootstrap();
