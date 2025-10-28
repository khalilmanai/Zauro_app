# 🚂 Railway Free Tier Deployment Guide - Zauro App

## 🎯 Overview

This guide will help you deploy the Zauro marketplace backend to Railway's **free tier** ($5/month credit). Railway is perfect for this project because:
- ✅ $5/month free credit (sufficient for small apps)
- ✅ PostgreSQL database included (free tier available)
- ✅ Docker native support
- ✅ Automatic deployments from GitHub
- ✅ Built-in SSL certificates
- ✅ Free `.railway.app` domain

---

## 📋 Prerequisites

1. **GitHub Account** - Your code must be on GitHub
2. **Railway Account** - Sign up at [railway.app](https://railway.app)
3. **Environment Variables** - Prepare all required secrets

---

## 🚀 Step-by-Step Deployment

### Step 1: Prepare Your GitHub Repository

Make sure your code is committed and pushed to GitHub:

```bash
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### Step 2: Create Railway Account

1. Go to [railway.app](https://railway.app)
2. Click "Login" → "Login with GitHub"
3. Authorize Railway to access your GitHub account
4. You'll see the Railway dashboard

### Step 3: Create New Project

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose your Zauro repository from the list
4. Railway will start deploying automatically

### Step 4: Add PostgreSQL Database

Since Railway uses individual services, you need to add PostgreSQL separately:

1. In your project, click **"+ New"**
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway will create a PostgreSQL database
4. **Save the connection URL** - you'll need this for the backend

### Step 5: Configure Backend Service

#### 5.1 Set Environment Variables

Click on your backend service → **"Variables"** tab, add:

```env
# Database
DATABASE_URL=<paste-the-postgresql-url-from-railway>

# Application
NODE_ENV=production
PORT=3000

# JWT Authentication
JWT_SECRET=<generate-a-strong-secret-minimum-32-characters>
JWT_REFRESH_SECRET=<generate-another-strong-secret-minimum-32-characters>
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Hedera Blockchain
HEDERA_ACCOUNT_ID=<your-hedera-account-id>
HEDERA_PRIVATE_KEY=<your-hedera-private-key>
HEDERA_NETWORK=testnet

# Optional: Email (if you want email features)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=<your-email>
SMTP_PASS=<your-app-password>
SMTP_FROM=<your-email>

# Optional: Twilio SMS (if you want SMS features)
TWILIO_ACCOUNT_SID=<your-twilio-sid>
TWILIO_AUTH_TOKEN=<your-twilio-token>
TWILIO_PHONE_NUMBER=<your-twilio-number>

# Optional: Supabase Storage (if you want file upload)
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-supabase-key>
SUPABASE_SERVICE_ROLE_KEY=<your-supabase-service-key>

# Encryption (important!)
ENCRYPTION_KEY=<generate-a-32-character-encryption-key>

# Performance
THROTTLE_TTL=60
THROTTLE_LIMIT=10
```

**💡 Pro Tips:**
- **Generate strong secrets**: Use `openssl rand -base64 32` or an online password generator
- **Keep these secrets safe**: They won't be visible again in Railway's UI
- **DATABASE_URL**: Railway provides this automatically when you add PostgreSQL

#### 5.2 Update Railway Configuration

Railway will use `railway.toml` for build settings. The existing configuration should work, but verify:

The `railway.toml` file should look like this:
```toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile.production"

[deploy]
startCommand = "node dist/main.js"
healthcheckPath = "/api/v1/health"
healthcheckTimeout = 300
restartPolicyType = "always"

[env]
NODE_ENV = "production"
PORT = "3000"
```

### Step 6: Deploy!

1. Railway will automatically build and deploy your app
2. Click **"Deployments"** to see build logs
3. Wait for "Build Successful" and "Service is running"
4. Open **"Settings"** → **"Domain"** to get your public URL

### Step 7: Verify Deployment

Your API will be available at:
```
https://your-project-name.railway.app/api/v1/health
```

Test endpoints:
- Health: `https://your-url.railway.app/api/v1/health`
- Docs: `https://your-url.railway.app/api/docs` (Swagger UI)
- Animals: `https://your-url.railway.app/api/v1/animals`

---

## 🔧 Railway Free Tier Limits & Optimizations

### Free Tier Limits:
- 💰 **$5/month credit** (about 500 hours of usage)
- 📊 **512MB RAM** per service
- 💾 **1GB disk space**
- 🗄️ **256MB PostgreSQL database**
- ⏱️ **No sleep mode** (unlike Render)

### Optimizations for Free Tier:

#### 1. Reduce Memory Usage
Edit `Dockerfile.production` and add Node.js memory limits:

```dockerfile
# Add to CMD in Dockerfile.production
CMD ["node", "--max-old-space-size=384", "dist/main.js"]
```

#### 2. Optimize Database Queries
- Keep database size small
- Use database indexes appropriately
- Monitor database usage in Railway dashboard

#### 3. Use Railway's Watch Feature (Free Tier Benefit)
Railway watches your GitHub repo for changes and auto-deploys:
- Push to main branch → Auto-deploy
- Perfect for CI/CD without extra cost

---

## 🐛 Troubleshooting

### Issue: Build Fails
**Solution:**
```bash
# Check Railway logs
# Ensure Dockerfile.production exists
# Verify all dependencies in package.json
```

### Issue: Database Connection Error
**Solution:**
```bash
# Verify DATABASE_URL in environment variables
# Ensure PostgreSQL service is running
# Check database credentials
```

### Issue: Out of Memory
**Solution:**
```bash
# Add memory limit to Dockerfile.production
CMD ["node", "--max-old-space-size=384", "dist/main.js"]
```

### Issue: Health Check Failing
**Solution:**
```bash
# Ensure health endpoint exists in your app
# Check the healthcheckPath in railway.toml
# Verify PORT environment variable
```

### Issue: Missing Environment Variables
**Solution:**
```bash
# Add all required variables from env.example
# Restart the service after adding variables
```

---

## 💡 Tips for Staying Within Free Tier

1. **Monitor Usage**: Check "Usage" tab in Railway dashboard regularly
2. **Optimize Build Time**: Use multi-stage Docker builds (already done)
3. **Database Size**: Keep database under 256MB
4. **Memory Usage**: Keep services lightweight
5. **Scale Smart**: Only scale when necessary

### Recommended Settings for Free Tier:

```env
# In Railway environment variables
NODE_ENV=production
NODE_OPTIONS=--max-old-space-size=384

# Reduce logging (optional)
LOG_LEVEL=error
```

---

## 📊 Monitoring Your Deployment

### Railway Dashboard Features:
- ✅ **Real-time logs**: See what's happening in real-time
- ✅ **Metrics**: CPU, memory, and network usage
- ✅ **Deployments**: View build history
- ✅ **Custom domains**: Add your own domain (optional)

### Useful Commands:

```bash
# SSH into your deployment (not available on free tier)
# Use Railway dashboard instead

# View logs
# Go to "Deployments" → Click on latest deployment → View logs
```

---

## 🔐 Security Best Practices

1. **Never commit `.env` files** to GitHub
2. **Use Railway's secrets** for sensitive data
3. **Generate strong secrets** for JWT keys
4. **Enable HTTPS** (Railway does this automatically)
5. **Set up CORS** properly in your NestJS app

---

## 🎯 Alternative: Skip Animal Detection Service (Free Tier Optimization)

If you're hitting free tier limits, you can deploy without the animal detection ML service:

1. The main backend will work without it
2. Only AI analysis features will be unavailable
3. Save resources for the core features

To skip the ML service:
- Don't add it as a separate service in Railway
- Comment out ML service calls in your code temporarily

---

## 📈 Scaling Beyond Free Tier

When you need more resources:

1. **Upgrade Plan**: Railway offers $5/month Hobby plan
2. **Optimize First**: Try optimizations before upgrading
3. **Monitor Usage**: Use Railway's metrics to see what you need
4. **Add Resources Gradually**: Add only what you need

---

## ✅ Deployment Checklist

- [ ] Code pushed to GitHub
- [ ] Railway account created
- [ ] Project deployed from GitHub
- [ ] PostgreSQL database added
- [ ] Environment variables set
- [ ] Build successful
- [ ] Health endpoint responding
- [ ] API documentation accessible
- [ ] Custom domain configured (optional)

---

## 🆘 Need Help?

- **Railway Docs**: [docs.railway.app](https://docs.railway.app)
- **Railway Discord**: [discord.gg/railway](https://discord.gg/railway)
- **Support**: Check Railway dashboard for support options

---

## 🎉 Success!

Your Zauro marketplace is now live on Railway!

**Next Steps:**
1. Update your frontend to use the Railway URL
2. Test all API endpoints
3. Monitor usage in Railway dashboard
4. Share your deployed app!

---

**Happy Deploying! 🚂**

