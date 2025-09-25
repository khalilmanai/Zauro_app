# 🐾 Zauro Marketplace Flutter App

A comprehensive Flutter application for the Zauro blockchain-based animal marketplace, featuring NFT trading, wallet management, and secure authentication.

## 📱 Features

### 🔐 Authentication & Security
- **JWT-based Authentication** with refresh token support
- **Secure Registration** with email/phone verification
- **Password Recovery** with OTP via email/SMS
- **Biometric Authentication** (fingerprint/face recognition)
- **Role-based Access Control** (Admin, HR/Manager, Employee/Trader)

### 🐾 Animal Management
- **Animal Registration** with comprehensive metadata
- **NFT Minting** automatic blockchain integration
- **Image Upload** with camera and gallery support
- **Veterinary Records** PDF document management
- **AI Valuation** intelligent price prediction
- **Ownership Tracking** immutable blockchain records

### 🔄 Trading & Marketplace
- **Animal Listings** with detailed information
- **Advanced Search** and filtering capabilities
- **Real-time Trading** with atomic swap execution
- **Trade History** comprehensive transaction logs
- **Price Analytics** market trends and insights
- **Notifications** real-time trade updates

### 💰 Wallet Integration
- **Hedera Wallet** custodial wallet management
- **Balance Tracking** HBAR and ZAU tokens
- **Transaction History** detailed blockchain records
- **Secure Storage** encrypted private keys
- **QR Code Support** easy address sharing

### 🎨 User Interface
- **Modern Design** Material Design 3 principles
- **Dark/Light Theme** adaptive theme support
- **Responsive Layout** optimized for all screen sizes
- **Smooth Animations** enhanced user experience
- **Accessibility** comprehensive accessibility support

## 🏗️ Architecture

### State Management
- **Riverpod** for reactive state management
- **Provider Pattern** dependency injection
- **Repository Pattern** clean architecture
- **MVVM Architecture** separation of concerns

### Network Layer
- **Retrofit + Dio** type-safe HTTP client
- **JWT Interceptors** automatic token management
- **Error Handling** comprehensive error management
- **Offline Support** local caching capabilities

### Data Persistence
- **Hive** local database storage
- **Secure Storage** encrypted sensitive data
- **Shared Preferences** user settings
- **Cache Management** efficient data caching

### File Management
- **Image Picker** camera and gallery integration
- **File Upload** multipart form data support
- **Compression** automatic image optimization
- **Validation** file type and size checks

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0+
- Dart SDK 3.0.0+
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure backend URL**
   ```dart
   // lib/core/config/app_config.dart
   static const String baseUrl = 'https://your-api-url.com';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core Dependencies
```yaml
# State Management
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3

# HTTP Client
dio: ^5.4.0
retrofit: ^4.0.3
json_annotation: ^4.8.1

# Storage & Persistence
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0
hive: ^2.2.3
hive_flutter: ^1.1.0

# UI Components
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
cached_network_image: ^3.3.0
shimmer: ^3.0.0

# Navigation
go_router: ^12.1.3

# File Handling
image_picker: ^1.0.4
file_picker: ^6.1.1
permission_handler: ^11.2.0

# Utilities
intl: ^0.19.0
connectivity_plus: ^5.0.2
```

## 📱 Screens Overview

### Authentication Flow
- **Onboarding Screen** - App introduction and features
- **Login Screen** - User authentication
- **Register Screen** - New user registration
- **Forgot Password Screen** - Password recovery with OTP

### Main Application
- **Home Screen** - Dashboard with overview
- **Animals List** - User's animals with search/filter
- **Animal Detail** - Detailed animal information
- **Add Animal** - Register new animal with NFT minting
- **Marketplace** - Browse available animals for trade
- **Trade Detail** - Trading interface with atomic swaps
- **Wallet Screen** - Balance and transaction history
- **Profile Screen** - User settings and preferences

## 🎯 Key Features Implementation

### 1. Authentication System
```dart
// JWT token management with automatic refresh
class AuthRepository {
  Future<AuthResponse> login({
    required String email,
    required String password,
  });
  
  Future<void> logout();
  Future<String> refreshToken();
}
```

### 2. Animal Management
```dart
// NFT-based animal registration
class AnimalsRepository {
  Future<Animal> createAnimal({
    required CreateAnimalRequest request,
    File? imageFile,
    File? vetRecordFile,
  });
  
  Future<List<Animal>> getAnimals({
    AnimalFilter? filter,
    int page = 1,
  });
}
```

### 3. Trading System
```dart
// Atomic swap trading
class TradingRepository {
  Future<Trade> createTrade(CreateTradeRequest request);
  Future<Trade> buyAnimal(String tradeId);
  Future<Trade> executeTrade(String tradeId);
}
```

### 4. Wallet Integration
```dart
// Hedera wallet management
class WalletRepository {
  Future<Wallet> createWallet();
  Future<WalletBalance> getBalance();
  Future<List<Transaction>> getTransactions();
}
```

## 🔒 Security Features

### Data Protection
- **AES Encryption** for sensitive data
- **Secure Storage** for tokens and keys
- **Certificate Pinning** for API security
- **Input Validation** comprehensive form validation

### Authentication Security
- **JWT Tokens** with short expiration
- **Refresh Token Rotation** enhanced security
- **Biometric Authentication** device-level security
- **Session Management** secure session handling

## 🎨 UI/UX Features

### Design System
- **Custom Theme** consistent color palette
- **Typography** Poppins font family
- **Components** reusable UI components
- **Animations** smooth transitions and micro-interactions

### Responsive Design
- **Adaptive Layouts** works on all screen sizes
- **Orientation Support** portrait and landscape
- **Accessibility** screen reader and keyboard navigation
- **Internationalization** multi-language support ready

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test/
```

## 📱 Platform Support

### Android
- **Minimum SDK**: Android 5.0 (API level 21)
- **Target SDK**: Android 14 (API level 34)
- **Permissions**: Camera, Storage, Internet, Biometric

### iOS
- **Minimum Version**: iOS 12.0
- **Target Version**: iOS 17.0
- **Permissions**: Camera, Photo Library, Biometric ID

## 🚀 Deployment

### Android Release
```bash
flutter build appbundle --release
```

### iOS Release
```bash
flutter build ios --release
```

### Configuration
- **Environment Variables** for different build flavors
- **Code Signing** for iOS App Store
- **ProGuard Rules** for Android optimization
- **Metadata** app store descriptions and screenshots

## 🔄 CI/CD Pipeline

### GitHub Actions
```yaml
# Automated testing and building
- Unit Tests
- Integration Tests
- Code Coverage
- Static Analysis
- Build APK/IPA
- Deploy to App Store/Play Store
```

## 📊 Performance Optimization

### App Performance
- **Lazy Loading** efficient memory usage
- **Image Caching** reduced network requests
- **Code Splitting** modular architecture
- **Bundle Size** optimized app size

### Network Performance
- **Request Caching** reduced API calls
- **Compression** optimized data transfer
- **Retry Logic** robust error handling
- **Offline Support** local data storage

## 🔧 Development Tools

### Code Generation
```bash
# Generate model classes
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Debugging
- **Flutter Inspector** UI debugging
- **Network Inspector** API call monitoring
- **Performance Profiler** performance analysis
- **Crash Reporting** error tracking

## 📈 Analytics & Monitoring

### User Analytics
- **Screen Tracking** user navigation patterns
- **Event Tracking** user interactions
- **Crash Reporting** error monitoring
- **Performance Monitoring** app performance metrics

### Business Analytics
- **Trade Volume** transaction metrics
- **User Engagement** app usage statistics
- **Revenue Tracking** monetization metrics
- **Feature Usage** feature adoption rates

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit pull request

### Code Standards
- **Dart Style Guide** consistent code formatting
- **Documentation** comprehensive code comments
- **Testing** unit and widget tests required
- **Code Review** peer review process

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation
- **API Documentation** backend integration guide
- **Widget Catalog** UI component library
- **Architecture Guide** technical documentation
- **Troubleshooting** common issues and solutions

### Community
- **GitHub Issues** bug reports and feature requests
- **Discussions** community support and questions
- **Wiki** additional documentation and guides
- **Changelog** version history and updates

---

**Built with ❤️ for the Zauro Marketplace**

*Empowering animal trading through blockchain technology on mobile devices*
