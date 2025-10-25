# 🚀 Zauro Platform - Free Deployment Guide

## 🏆 Recommended: Railway Deployment

### Why Railway?
- ✅ **Free tier**: $5 credit monthly (sufficient for small apps)
- ✅ **Docker native**: Perfect for your Docker Compose setup
- ✅ **PostgreSQL included**: No separate database setup needed
- ✅ **GitHub integration**: Automatic deployments
- ✅ **Custom domains**: Professional URLs
- ✅ **Easy scaling**: Upgrade when needed

### Step-by-Step Railway Deployment:

#### 1. Prepare Your Repository
```bash
# Ensure your code is on GitHub
git add .
git commit -m "Ready for deployment"
git push origin main
```

#### 2. Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Connect your repository

#### 3. Deploy Backend
1. Click "New Project" → "Deploy from GitHub repo"
2. Select your Zauro repository
3. Railway will detect your `docker-compose.yml`
4. Set environment variables:
   ```
   DATABASE_URL=postgresql://postgres:password@postgres:5432/zauro_db
   JWT_SECRET=your-super-secret-jwt-key-here
   HEDERA_ACCOUNT_ID=0.0.6159428
   HEDERA_PRIVATE_KEY=your-hedera-private-key
   HEDERA_NETWORK=testnet
   ```

#### 4. Deploy Database
1. Add PostgreSQL service
2. Railway will provide `DATABASE_URL` automatically
3. Update your backend environment variables

#### 5. Configure Domain
1. Go to Settings → Domains
2. Add custom domain (optional)
3. Railway provides free `.railway.app` domain

---

## 🌊 Alternative: Render Deployment

### Why Render?
- ✅ **Free tier**: 750 hours/month
- ✅ **Docker support**: Native container deployment
- ✅ **PostgreSQL**: Managed database
- ✅ **Auto-deploy**: GitHub integration
- ⚠️ **Sleep mode**: App sleeps after 15 min inactivity

### Step-by-Step Render Deployment:

#### 1. Prepare Dockerfile
Create `Dockerfile.production`:
```dockerfile
FROM node:22-alpine AS base
WORKDIR /app
RUN apk add --no-cache libc6-compat python3 make g++ openssl

FROM base AS builder
COPY package*.json ./
RUN npm ci
COPY . ./
RUN npx prisma generate
RUN npm run build

FROM base AS runner
ENV NODE_ENV=production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY prisma ./prisma
COPY --from=builder /app/dist ./dist
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

#### 2. Deploy to Render
1. Go to [render.com](https://render.com)
2. Sign up with GitHub
3. Create "Web Service"
4. Connect your repository
5. Configure:
   - **Build Command**: `npm install && npx prisma generate && npm run build`
   - **Start Command**: `node dist/main.js`
   - **Environment**: `Node`

#### 3. Add PostgreSQL Database
1. Create "PostgreSQL" service
2. Copy connection string
3. Add to backend environment variables

---

## 🐳 Docker Hub + VPS Deployment

### Free VPS Options:

#### Oracle Cloud (Always Free)
- **Specs**: 1/8 OCPU, 1GB RAM, 10GB storage
- **Duration**: Forever free
- **Setup**: Ubuntu 20.04/22.04

#### Google Cloud Platform
- **Specs**: 1 vCPU, 0.6GB RAM, 30GB storage
- **Duration**: 12 months free
- **Setup**: Ubuntu 20.04

### Deployment Steps:

#### 1. Build and Push Docker Images
```bash
# Build images
docker build -t zauro-backend .
docker build -t zauro-db -f Dockerfile.postgres .

# Tag for Docker Hub
docker tag zauro-backend yourusername/zauro-backend:latest
docker tag zauro-db yourusername/zauro-db:latest

# Push to Docker Hub
docker push yourusername/zauro-backend:latest
docker push yourusername/zauro-db:latest
```

#### 2. Deploy on VPS
```bash
# SSH into your VPS
ssh user@your-vps-ip

# Install Docker
sudo apt update
sudo apt install docker.io docker-compose -y

# Clone your repo
git clone https://github.com/yourusername/zauro-app.git
cd zauro-app

# Update docker-compose.yml to use Docker Hub images
# Deploy
docker-compose up -d
```

---

## 🔧 Environment Variables Setup

### Required Environment Variables:
```bash
# Database
DATABASE_URL=postgresql://username:password@host:port/database

# JWT
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your-refresh-secret-key-minimum-32-characters
JWT_REFRESH_EXPIRES_IN=30d

# Hedera
HEDERA_ACCOUNT_ID=0.0.6159428
HEDERA_PRIVATE_KEY=your-hedera-private-key
HEDERA_NETWORK=testnet

# Email (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# SMS (Optional)
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=your-twilio-number

# Supabase (Optional)
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
```

---

## 🚀 Quick Start Commands

### For Railway:
```bash
# 1. Push to GitHub
git add .
git commit -m "Deploy to Railway"
git push origin main

# 2. Connect to Railway
# 3. Set environment variables
# 4. Deploy!
```

### For Render:
```bash
# 1. Create production Dockerfile
# 2. Push to GitHub
git add .
git commit -m "Deploy to Render"
git push origin main

# 3. Connect to Render
# 4. Configure build settings
# 5. Deploy!
```

### For VPS:
```bash
# 1. Build and push images
docker build -t yourusername/zauro-backend .
docker push yourusername/zauro-backend

# 2. Deploy on VPS
ssh user@vps-ip
git clone https://github.com/yourusername/zauro-app.git
cd zauro-app
docker-compose up -d
```

---

## 📊 Cost Comparison

| Provider | Free Tier | Limitations | Best For |
|----------|-----------|-------------|----------|
| **Railway** | $5/month credit | Usage-based | Production apps |
| **Render** | 750 hours/month | Sleeps after 15min | Development/testing |
| **Oracle Cloud** | Always free | 1GB RAM limit | Full control |
| **GCP** | 12 months free | Time-limited | Learning/experiments |
| **AWS** | 12 months free | Complex setup | Enterprise |

---

## 🎯 Recommendations

### For Production:
1. **Railway** - Best balance of features and cost
2. **Oracle Cloud** - If you need full control
3. **Render** - If you're okay with sleep mode

### For Development:
1. **GitHub Codespaces** - Quick setup
2. **Render** - Free tier sufficient
3. **Local Docker** - Full control

### For Learning:
1. **Railway** - Easiest deployment
2. **Oracle Cloud** - Learn cloud management
3. **Docker Hub + VPS** - Learn DevOps

---

## 🔒 Security Considerations

### Before Going Live:
1. **Change default passwords**
2. **Use strong JWT secrets**
3. **Enable HTTPS** (Railway/Render provide automatically)
4. **Set up monitoring**
5. **Backup your database**
6. **Use environment variables for secrets**

### Production Checklist:
- [ ] Strong passwords and secrets
- [ ] HTTPS enabled
- [ ] Database backups configured
- [ ] Monitoring set up
- [ ] Error logging configured
- [ ] Rate limiting enabled
- [ ] CORS properly configured

---

## 🆘 Troubleshooting

### Common Issues:

#### Database Connection Errors:
```bash
# Check DATABASE_URL format
DATABASE_URL=postgresql://user:pass@host:port/db

# Verify database is running
docker-compose ps
```

#### Build Failures:
```bash
# Check Node.js version
node --version  # Should be 18+

# Clear npm cache
npm cache clean --force
```

#### Environment Variables:
```bash
# Verify all required variables are set
echo $DATABASE_URL
echo $JWT_SECRET
echo $HEDERA_ACCOUNT_ID
```

---

## 📞 Support

- **Railway**: [docs.railway.app](https://docs.railway.app)
- **Render**: [render.com/docs](https://render.com/docs)
- **Docker**: [docs.docker.com](https://docs.docker.com)
- **Hedera**: [docs.hedera.com](https://docs.hedera.com)

---

**Happy Deploying! 🚀**
