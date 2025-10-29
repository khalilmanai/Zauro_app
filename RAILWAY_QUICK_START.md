# 🚀 Quick Start: Deploy to Railway Free Tier

This is a quick reference guide. For detailed instructions, see [RAILWAY_FREE_TIER_DEPLOYMENT.md](./RAILWAY_FREE_TIER_DEPLOYMENT.md).

## ⚡ 5-Minute Setup

### 1️⃣ Push to GitHub
```bash
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### 2️⃣ Create Railway Project
1. Go to [railway.app](https://railway.app) → Login with GitHub
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your Zauro repository
4. Railway starts deploying automatically

### 3️⃣ Add PostgreSQL Database
- Click "+ New" → "Database" → "Add PostgreSQL"
- Railway auto-generates connection URL
- Copy the `POSTGRES_URL` (you'll need it)

### 4️⃣ Configure Environment Variables

In your service → "Variables" tab, add:

```env
# Database (provided by Railway)
DATABASE_URL=<from-railway-postgresql-service>

# Required Secrets
NODE_ENV=production
JWT_SECRET=<generate-strong-secret-min-32-chars>
JWT_REFRESH_SECRET=<generate-another-secret-min-32-chars>

# Hedera Blockchain
HEDERA_ACCOUNT_ID=<your-account-id>
HEDERA_PRIVATE_KEY=<your-private-key>
HEDERA_NETWORK=testnet

# Encryption
ENCRYPTION_KEY=<32-character-key>
```

**Generate secrets:**
```bash
# JWT secrets
openssl rand -base64 32

# Encryption key
openssl rand -hex 16
```

### 5️⃣ Deploy & Test

1. Railway deploys automatically after setting variables
2. Get your URL: Service → "Settings" → "Domain"
3. Test: `https://your-url.railway.app/health`
4. API Docs: `https://your-url.railway.app/docs`

---

## ✅ What's Been Configured for You

- ✅ `Dockerfile.production` - Optimized for free tier
- ✅ `railway.toml` - Railway configuration
- ✅ Health check endpoint `/health`
- ✅ CORS configured for Railway domains
- ✅ Memory optimization (384MB limit)
- ✅ Automatic database migrations

---

## 🎯 Environment Variables Reference

Copy from `env.example` and update with your values:

| Variable | Required | Example |
|----------|----------|---------|
| `DATABASE_URL` | ✅ | `postgresql://postgres:pass@host:5432/db` |
| `JWT_SECRET` | ✅ | `generated-32-char-secret` |
| `JWT_REFRESH_SECRET` | ✅ | `generated-32-char-secret` |
| `HEDERA_ACCOUNT_ID` | ✅ | `0.0.123456` |
| `HEDERA_PRIVATE_KEY` | ✅ | `302e0201...` |
| `ENCRYPTION_KEY` | ✅ | `32-character-key` |
| `SMTP_*` | ⚪ Optional | Email features |
| `TWILIO_*` | ⚪ Optional | SMS features |
| `SUPABASE_*` | ⚪ Optional | File storage |

---

## 🔍 Troubleshooting

### Build Fails?
```bash
# Check Railway logs → Deployments → Latest build
# Verify Dockerfile.production exists
```

### Database Error?
```bash
# Verify DATABASE_URL is correct
# Check PostgreSQL service is running
```

### Out of Memory?
```
# Already optimized with --max-old-space-size=384
# Check "Metrics" tab in Railway dashboard
```

---

## 📊 Free Tier Limits

- 💰 **$5/month credit** (~500 hours)
- 🧠 **512MB RAM per service**
- 💾 **1GB disk space**
- 🗄️ **256MB PostgreSQL** (managed)
- ⚡ **No sleep mode** (always on)

---

## 🎉 Done!

Your API is live at: `https://your-url.railway.app`

- 📚 Swagger: `https://your-url.railway.app/docs`
- ❤️ Health: `https://your-url.railway.app/health`
- 🐾 API: `https://your-url.railway.app/api/v1/`

**Next:** Update frontend to use the Railway URL!

