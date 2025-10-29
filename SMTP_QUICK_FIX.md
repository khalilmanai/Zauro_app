# 🔧 Fix SMTP Timeout - Quick Guide

## Option 1: Use Mailtrap (Easiest for Testing)

**Railway Variables to Add:**
```env
SMTP_HOST=smtp.mailtrap.io
SMTP_PORT=2525
SMTP_USER=your-mailtrap-username
SMTP_PASS=your-mailtrap-password
SMTP_FROM=medkhalilmannai@gmail.com
SMTP_SECURE=false
```

**Steps:**
1. Sign up at https://mailtrap.io (free)
2. Create an inbox
3. Copy SMTP credentials
4. Update Railway variables
5. Redeploy

---

## Option 2: Fix Brevo Credentials

**Check your Brevo account:**
1. Go to https://www.brevo.com
2. Login
3. Go to **SMTP & API** settings
4. Click **SMTP** tab
5. Verify credentials match what's in Railway

**Common issues:**
- Wrong SMTP server (should be `smtp-relay.brevo.com`)
- Wrong port (should be `587` for TLS)
- Wrong username/password
- Account not verified

---

## Option 3: Disable SMTP Temporarily

**If you don't need emails right now:**

Remove these variables from Railway:
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USER`
- `SMTP_PASS`

Your app will still work, just email features won't function.

---

## 📝 Also Fix This!

I noticed your `DATABASE_URL` in Railway is still wrong:

**Current (BROKEN):**
```
DATABASE_URL=${{351550a3-9b4c-46b6-bec3-9a9383d7a0d4.DATABASE_URL}}/zauro_db
```

**Fix:**
1. Railway Dashboard → PostgreSQL service → Variables
2. Copy the actual `DATABASE_URL` (it looks like `postgresql://postgres:...@...:5432/railway`)
3. Paste it into backend service variables
4. **Remove the `/zauro_db` suffix**

The database name doesn't matter - Railway provides the correct URL!

---

**Your app is working!** The SMTP error won't crash it - just email features are disabled.

