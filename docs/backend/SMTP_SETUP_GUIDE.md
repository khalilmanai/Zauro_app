# SMTP Email Configuration Guide

## Overview

The Zauro backend now uses **nodemailer** with raw SMTP configuration instead of third-party APIs like MailerSend. This provides more flexibility and works with any SMTP server.

## Environment Variables

Add the following variables to your `.env` file:

```bash
# SMTP Email Service Configuration
SMTP_HOST="smtp.mailtrap.io"          # Your SMTP server hostname
SMTP_PORT=587                         # SMTP port (587 for TLS, 465 for SSL, 25 for plain)
SMTP_SECURE=false                     # true for SSL (port 465), false for TLS (port 587)
SMTP_USER="your-smtp-username"        # SMTP authentication username
SMTP_PASS="your-smtp-password"        # SMTP authentication password
SMTP_FROM="noreply@yourdomain.com"    # From email address
```

## Popular SMTP Providers

### Development/Testing
- **Mailtrap**: `smtp.mailtrap.io:587` (Free testing)
- **MailHog**: `localhost:1025` (Local testing)

### Production
- **Gmail**: `smtp.gmail.com:587` (requires app password)
- **Outlook**: `smtp-mail.outlook.com:587`
- **SendGrid**: `smtp.sendgrid.net:587`
- **Amazon SES**: `email-smtp.us-east-1.amazonaws.com:587`
- **Custom SMTP**: Your own SMTP server

## Email Functions

The `MailService` now provides a generic `sendMail` function:

```typescript
await mailService.sendMail(
  'user@example.com',           // to
  'Subject',                    // subject
  'Plain text content',         // text
  '<h1>HTML content</h1>'       // html (optional)
);
```

## Existing Email Methods

All existing methods continue to work:

- `sendPasswordResetOtp(email, otp)` - Send OTP for password reset
- `sendWelcomeEmail(email, firstName)` - Send welcome email to new users
- `sendTradeNotification(email, tradeType, animalName)` - Send trade notifications

## Error Handling

- The service logs all email sending attempts
- Returns `boolean` for the generic `sendMail` method
- Throws errors for specific methods if sending fails
- Includes SMTP connection verification on startup

## Features

✅ **Generic SMTP Support** - Works with any SMTP server  
✅ **No Domain Restrictions** - Send to any email address  
✅ **Environment Configuration** - All settings in `.env`  
✅ **Error Handling** - Comprehensive logging and error handling  
✅ **HTML & Text** - Support for both HTML and plain text emails  
✅ **Connection Verification** - Tests SMTP connection on startup  

## Migration Notes

- Removed dependency on `mailersend` package
- Added `nodemailer` and `@types/nodemailer`
- Updated configuration in `src/config/configuration.ts`
- All existing email functionality preserved
- No changes required to controllers or other services
