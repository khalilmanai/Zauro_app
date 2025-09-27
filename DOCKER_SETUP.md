# 🐳 Zauro Marketplace - Docker Setup Guide

## 📋 Overview

This guide provides comprehensive instructions for dockerizing and running the Zauro Marketplace application using Docker and Docker Compose. The setup includes:

- **NestJS Backend API** (Port 3000)
- **Hedera Blockchain Service** (Port 3001)
- **PostgreSQL Database** (Port 5432)
- **Redis Cache** (Port 6379)
- **Nginx Reverse Proxy** (Port 80/443)

## 🚀 Quick Start

### Prerequisites

- Docker Desktop (v20.10+)
- Docker Compose (v2.0+)
- Git

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd Zauro_app

# Copy environment file
cp env.example .env

# Edit environment variables
nano .env
```

### 2. Configure Environment Variables

Edit `.env` file with your actual values:

```env
# Database Configuration
DATABASE_URL="postgresql://zauro_user:zauro_password@postgres:5432/zauro_db"
POSTGRES_DB="zauro_db"
POSTGRES_USER="zauro_user"
POSTGRES_PASSWORD="zauro_password"

# JWT Secrets (Required)
JWT_SECRET="your-super-secret-jwt-key-change-in-production-min-32-chars"
JWT_REFRESH_SECRET="your-super-secret-refresh-jwt-key-change-in-production-min-32-chars"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="7d"

# Hedera Blockchain Configuration (Required)
HEDERA_OPERATOR_ID="0.0.1234567"
HEDERA_OPERATOR_KEY="302e020100300506032b657004220420..."
HEDERA_NETWORK="testnet"
HEDERA_MIRROR_NODE_URL="https://testnet.mirrornode.hedera.com"
HEDERA_SUPPLY_KEY="302e020100300506032b657004220420..."
HEDERA_COLLECTION_TOKEN_ID="0.0.123456"

# Supabase Storage (Required)
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_ANON_KEY="your-supabase-anon-key"
SUPABASE_SERVICE_ROLE_KEY="your-supabase-service-role-key"

# SMTP Configuration (Optional)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT="587"
SMTP_SECURE="false"
SMTP_USER="your-email@gmail.com"
SMTP_PASS="your-app-password"
SMTP_FROM="noreply@yourdomain.com"

# Twilio SMS (Optional)
TWILIO_ACCOUNT_SID="your-twilio-account-sid"
TWILIO_AUTH_TOKEN="your-twilio-auth-token"
TWILIO_PHONE_NUMBER="+1234567890"

# Security (Required)
ENCRYPTION_KEY="your-32-character-encryption-key-here"

# Performance Settings
THROTTLE_TTL="60"
THROTTLE_LIMIT="10"
OTP_EXPIRES_IN_MINUTES="10"
OTP_LENGTH="6"
MAX_FILE_SIZE="10485760"
ALLOWED_FILE_TYPES="image/jpeg,image/png,image/gif,application/pdf"
```

### 3. Build and Run

```bash
# Build and start all services
docker-compose up --build -d

# View logs
docker-compose logs -f

# Check service status
docker-compose ps
```

### 4. Initialize Database

```bash
# Run database migrations
docker-compose exec backend npx prisma migrate deploy

# Seed the database (optional)
docker-compose exec backend npm run db:seed
```

## 🔧 Service Details

### Backend API (Port 3000)
- **Service**: `backend`
- **Container**: `zauro-backend`
- **Health Check**: `http://localhost:3000/api/v1/health`
- **Features**: User management, authentication, wallet operations, NFT management

### Hedera Service (Port 3001)
- **Service**: `hedera-service`
- **Container**: `zauro-hedera`
- **Health Check**: `http://localhost:3001/collection-status`
- **Features**: Blockchain operations, NFT minting, wallet creation

### PostgreSQL Database (Port 5432)
- **Service**: `postgres`
- **Container**: `zauro-postgres`
- **Database**: `zauro_db`
- **User**: `zauro_user`
- **Password**: `zauro_password`

### Redis Cache (Port 6379)
- **Service**: `redis`
- **Container**: `zauro-redis`
- **Features**: Session storage, caching, rate limiting

### Nginx Proxy (Port 80)
- **Service**: `nginx`
- **Container**: `zauro-nginx`
- **Features**: Load balancing, SSL termination, rate limiting

## 📡 API Endpoints

### Backend API Routes
- `http://localhost/api/v1/auth/*` - Authentication
- `http://localhost/api/v1/wallets/*` - Wallet operations
- `http://localhost/api/v1/animals/*` - Animal management
- `http://localhost/api/v1/trades/*` - Trading operations

### Hedera Blockchain Routes
- `http://localhost/hedera/create-wallet` - Create Hedera wallet
- `http://localhost/hedera/mint-nft` - Mint NFT
- `http://localhost/hedera/transfer-nft` - Transfer NFT
- `http://localhost/hedera/collection-status` - Collection status

### Direct Blockchain Access
- `http://localhost/blockchain/*` - Direct Hedera service access

## 🛠️ Development Commands

### Build Services
```bash
# Build specific service
docker-compose build backend
docker-compose build hedera-service

# Build all services
docker-compose build
```

### Run Services
```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d backend

# Start with logs
docker-compose up
```

### Stop Services
```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Stop specific service
docker-compose stop backend
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f hedera-service

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Execute Commands
```bash
# Access backend container
docker-compose exec backend sh

# Run Prisma commands
docker-compose exec backend npx prisma migrate dev
docker-compose exec backend npx prisma generate
docker-compose exec backend npx prisma studio

# Access database
docker-compose exec postgres psql -U zauro_user -d zauro_db
```

## 🔍 Monitoring and Debugging

### Health Checks
```bash
# Check all service health
docker-compose ps

# Test API health
curl http://localhost/api/v1/health

# Test Hedera service
curl http://localhost/hedera/collection-status
```

### Resource Usage
```bash
# View resource usage
docker stats

# View specific container stats
docker stats zauro-backend
```

### Debugging
```bash
# View container logs
docker logs zauro-backend
docker logs zauro-hedera

# Access container shell
docker exec -it zauro-backend sh
docker exec -it zauro-hedera sh
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Database Migration Issues
**Error**: `The table 'public.users' does not exist in the current database`

**Solution**:
```bash
# Run database migrations
docker-compose exec backend npx prisma migrate deploy

# Or reset the database completely
docker-compose exec backend npx prisma migrate reset

# Check migration status
docker-compose exec backend npx prisma migrate status
```

#### 2. Backend Container Won't Start
**Error**: `Error: Cannot find module '/app/dist/main'`

**Solutions**:
```bash
# Check if TypeScript config files are present
docker-compose exec backend ls -la tsconfig*.json

# Verify development mode is enabled
docker-compose exec backend cat package.json | grep start:dev

# Rebuild with no cache
docker-compose build --no-cache backend
```

#### 3. Hedera Service Health Check Fails
**Error**: `container zauro-hedera is unhealthy`

**Solutions**:
```bash
# Check Hedera service logs
docker-compose logs hedera-service

# Test Hedera service directly
curl http://localhost:3001/collection-status

# Verify environment variables
docker-compose exec hedera-service env | grep HEDERA

# Restart Hedera service
docker-compose restart hedera-service
```

#### 4. Permission Denied Errors
**Error**: `EACCES: permission denied, rmdir '/app/dist'`

**Solution**:
```bash
# Check file ownership in container
docker-compose exec backend ls -la /app

# Rebuild container to fix permissions
docker-compose build --no-cache backend
```

#### 5. Port Already in Use
```bash
# Check what's using the port
netstat -tulpn | grep :3000
lsof -i :3000

# Kill the process
sudo kill -9 <PID>

# Or change ports in docker-compose.yml
```

#### 6. Database Connection Issues
```bash
# Check database logs
docker-compose logs postgres

# Test database connection
docker-compose exec postgres pg_isready -U zauro_user -d zauro_db

# Restart database
docker-compose restart postgres

# Reset database completely
docker-compose down -v
docker-compose up -d postgres
```

#### 7. Environment Variable Issues
**Error**: `The "HEDERA_OPERATOR_ID" variable is not set`

**Solutions**:
```bash
# Check if .env file exists
ls -la .env

# Verify environment variables are loaded
docker-compose config

# Check specific service environment
docker-compose exec backend env | grep HEDERA
```

#### 8. Build Issues
```bash
# Clean build
docker-compose down
docker system prune -f
docker-compose build --no-cache
docker-compose up -d

# Check build logs
docker-compose build backend 2>&1 | tee build.log
```

#### 9. Frontend Connection Issues
**Error**: Frontend can't connect to backend

**Solutions**:
```bash
# Verify backend is running
curl http://localhost:3000/api/v1/health

# Check CORS configuration
docker-compose exec backend cat src/main.ts | grep enableCors

# Test API endpoints
curl -X GET http://localhost:3000/api/v1/auth/profile
```

#### 10. Redis Connection Issues
```bash
# Check Redis logs
docker-compose logs redis

# Test Redis connection
docker-compose exec redis redis-cli ping

# Restart Redis
docker-compose restart redis
```

### Environment Issues

#### Missing Environment Variables
```bash
# Check if .env file exists
ls -la .env

# Verify environment variables are loaded
docker-compose config
```

#### Hedera Credentials
- Ensure you have valid Hedera testnet credentials
- Check the Hedera Portal for account status
- Verify sufficient HBAR balance for transactions

## 🔒 Security Considerations

### Production Deployment

1. **Change Default Passwords**
   ```env
   POSTGRES_PASSWORD=strong-random-password
   JWT_SECRET=very-long-random-secret
   ENCRYPTION_KEY=32-character-random-key
   ```

2. **Enable HTTPS**
   - Uncomment HTTPS configuration in `nginx.conf`
   - Add SSL certificates to `./ssl/` directory
   - Update environment variables for HTTPS

3. **Network Security**
   - Use Docker networks for service isolation
   - Implement proper firewall rules
   - Use secrets management for sensitive data

4. **Database Security**
   - Use strong passwords
   - Enable SSL connections
   - Regular backups
   - Access control

## 📊 Performance Optimization

### Resource Limits
Add to `docker-compose.yml`:
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
```

### Caching
- Redis is configured for session storage
- Implement application-level caching
- Use CDN for static assets

### Database Optimization
- Regular VACUUM and ANALYZE
- Proper indexing
- Connection pooling

## 🔄 Backup and Recovery

### Database Backup
```bash
# Create backup
docker-compose exec postgres pg_dump -U zauro_user zauro_db > backup.sql

# Restore backup
docker-compose exec -T postgres psql -U zauro_user zauro_db < backup.sql
```

### Volume Backup
```bash
# Backup volumes
docker run --rm -v zauro_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Hedera Documentation](https://docs.hedera.com/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## 🆘 Support

If you encounter issues:

1. Check the logs: `docker-compose logs -f`
2. Verify environment variables
3. Ensure all services are healthy: `docker-compose ps`
4. Check network connectivity
5. Review this documentation

For additional help, please refer to the project's main README or create an issue in the repository.
