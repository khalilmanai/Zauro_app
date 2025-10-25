# Zauro Marketplace - Production Deployment Guide

## Pre-Deployment Checklist

### 1. Environment Configuration
- [ ] Set production API URLs via environment variables
- [ ] Configure signing certificates for Android/iOS
- [ ] Set up proper encryption keys
- [ ] Configure Firebase/Analytics keys
- [ ] Verify all environment variables are set

### 2. Build Configuration
- [ ] Update package names (`com.zauro.marketplace`)
- [ ] Configure app icons and splash screens
- [ ] Set up proper signing configurations
- [ ] Enable code obfuscation and minification
- [ ] Configure ProGuard rules

### 3. Security Measures
- [ ] Remove all debug logging
- [ ] Enable certificate pinning
- [ ] Secure sensitive data storage
- [ ] Implement proper error handling
- [ ] Add crash reporting

## Environment Variables

Create a `.env` file or set the following environment variables:

```bash
# API Configuration
PROD_API_URL=https://api.zauro.com
STAGING_API_URL=https://staging-api.zauro.com
DEV_API_URL=http://localhost:3000

# Security
HIVE_ENCRYPTION_KEY=your-production-encryption-key
FIREBASE_API_KEY=your-firebase-api-key

# Signing (Android)
ZAURO_KEYSTORE_PATH=/path/to/release.jks
ZAURO_KEYSTORE_PASSWORD=your-keystore-password
ZAURO_KEY_ALIAS=your-key-alias
ZAURO_KEY_PASSWORD=your-key-password

# Analytics
ANALYTICS_TRACKING_ID=your-analytics-id
CRASHLYTICS_API_KEY=your-crashlytics-key
```

## Build Commands

### Android Production Build
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build APK
flutter build apk --release --dart-define=PROD_API_URL=https://api.zauro.com

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release --dart-define=PROD_API_URL=https://api.zauro.com

# Build with all environment variables
flutter build appbundle --release \
  --dart-define=PROD_API_URL=https://api.zauro.com \
  --dart-define=HIVE_ENCRYPTION_KEY=your-production-key \
  --dart-define=FIREBASE_API_KEY=your-firebase-key
```

### iOS Production Build
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build iOS
flutter build ios --release --dart-define=PROD_API_URL=https://api.zauro.com

# Build IPA (requires Xcode)
flutter build ipa --release --dart-define=PROD_API_URL=https://api.zauro.com
```

## App Store Preparation

### Android (Google Play Store)
1. **Create App Bundle**: Use `flutter build appbundle --release`
2. **Upload to Play Console**: Upload the `.aab` file
3. **Configure Store Listing**:
   - App name: "Zauro Marketplace"
   - Short description: "Blockchain-based Animal Trading Platform"
   - Full description: Include features and benefits
   - Screenshots: Provide screenshots for all device types
4. **Set up App Signing**: Let Google Play manage your app signing key
5. **Configure Releases**: Use internal testing → closed testing → production

### iOS (App Store)
1. **Build IPA**: Use `flutter build ipa --release`
2. **Upload to App Store Connect**: Use Xcode or Application Loader
3. **Configure App Information**:
   - Name: "Zauro Marketplace"
   - Bundle ID: `com.zauro.marketplace`
   - Category: Business or Finance
4. **Provide Screenshots**: For all required device sizes
5. **Set up App Store Review**: Provide demo account if needed

## Monitoring and Analytics

### Crash Reporting
```dart
// Add to main.dart
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  fatal: false,
);
```

### Performance Monitoring
```dart
// Add to critical operations
final trace = FirebasePerformance.instance.newTrace('api_call');
trace.start();
// ... perform operation
trace.stop();
```

### Analytics
```dart
// Track user events
FirebaseAnalytics.instance.logEvent(
  name: 'animal_purchased',
  parameters: {
    'animal_type': 'dog',
    'price': 100.0,
  },
);
```

## CI/CD Pipeline

### GitHub Actions Example
```yaml
name: Build and Deploy
on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
    
    - name: Install dependencies
      run: flutter pub get
      working-directory: ./frontend
    
    - name: Run tests
      run: flutter test
      working-directory: ./frontend
    
    - name: Build APK
      run: |
        flutter build apk --release \
          --dart-define=PROD_API_URL=${{ secrets.PROD_API_URL }} \
          --dart-define=FIREBASE_API_KEY=${{ secrets.FIREBASE_API_KEY }}
      working-directory: ./frontend
    
    - name: Upload to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
        packageName: com.zauro.marketplace
        releaseFiles: frontend/build/app/outputs/bundle/release/app-release.aab
        track: production
```

## Performance Optimization

### Image Optimization
- Use appropriate image formats (WebP for Android, HEIC for iOS)
- Implement lazy loading for images
- Use cached_network_image for remote images
- Compress images before uploading

### Code Optimization
- Enable code splitting
- Use const constructors where possible
- Implement proper state management
- Avoid rebuilding expensive widgets

### Network Optimization
- Implement proper caching strategies
- Use compression for API responses
- Implement retry mechanisms
- Add offline support where appropriate

## Security Best Practices

### Data Protection
- Encrypt sensitive data using flutter_secure_storage
- Use certificate pinning for API calls
- Implement proper authentication flows
- Validate all user inputs

### Code Protection
- Enable code obfuscation in release builds
- Remove debug information
- Use environment variables for sensitive configuration
- Implement proper error handling to avoid information leakage

## Post-Deployment Monitoring

### Key Metrics to Monitor
- App crashes and ANRs
- API response times
- User retention rates
- Feature usage analytics
- Performance metrics

### Alerting
Set up alerts for:
- Crash rate > 1%
- API errors > 5%
- App launch time > 3 seconds
- Memory usage > 200MB

## Rollback Strategy

### Android
- Use Play Console's rollback feature
- Keep previous version available
- Monitor crash rates for 24-48 hours

### iOS
- Submit new version to App Store
- Use phased rollout to limit impact
- Monitor App Store Connect for issues

## Support and Maintenance

### Regular Updates
- Security patches: Monthly
- Feature updates: Quarterly
- Dependency updates: As needed

### Monitoring Tools
- Firebase Crashlytics for crash reporting
- Firebase Performance for performance monitoring
- Firebase Analytics for user behavior
- Play Console/App Store Connect for store metrics

## Troubleshooting Common Issues

### Build Failures
1. **Gradle build failed**: Update Android Gradle Plugin
2. **iOS build failed**: Update Xcode and iOS deployment target
3. **Dependency conflicts**: Run `flutter pub deps` to check dependencies

### Runtime Issues
1. **App crashes on startup**: Check environment configuration
2. **API calls failing**: Verify network permissions and URLs
3. **Performance issues**: Use Flutter Inspector to identify bottlenecks

## Contact Information

For deployment support:
- Technical Lead: [email]
- DevOps Team: [email]
- Emergency Contact: [phone]

