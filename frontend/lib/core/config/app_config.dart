import 'package:flutter/foundation.dart';

class AppConfig {
  // App Information
  static const String appName = 'Zauro Marketplace';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Blockchain-based Animal Trading Platform';

  // Environment Detection
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isStaging => kProfileMode;

  // API Configuration
  static String get baseUrl {
    if (isProduction) {
      return const String.fromEnvironment(
        'PROD_API_BASE_URL',
        defaultValue: 'https://api.zauro.com',
      );
    } else if (isStaging) {
      return const String.fromEnvironment(
        'STAGING_API_BASE_URL',
        defaultValue: 'https://staging-api.zauro.com',
      );
    } else {
      return const String.fromEnvironment(
        'DEV_API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3002',
      );
    }
  }

  static const String apiPrefix = '/api/v1';
  static String get fullApiUrl => '$baseUrl$apiPrefix';

  // Legacy Configuration (deprecated)
  @Deprecated('Use baseUrl getter instead')
  static const String productionBaseUrl = 'https://api.zauro.com';
  @Deprecated('Use fullApiUrl getter instead')
  static const String productionApiUrl = '$productionBaseUrl$apiPrefix';

  // Endpoints
  static const String authEndpoint = '/auth';
  static const String animalsEndpoint = '/animals';
  static const String tradesEndpoint = '/trades';
  static const String walletsEndpoint = '/wallets';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';

  // Hive Box Names
  static const String userBoxName = 'user_box';
  static const String cacheBoxName = 'cache_box';

  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
  ];
  static const List<String> allowedDocumentTypes = ['application/pdf'];

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Network Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // OTP Configuration
  static const int otpLength = 6;
  static const Duration otpExpiration = Duration(minutes: 10);

  // Animal Species
  static const List<String> animalSpecies = [
    'COW',
    'GOAT',
    'SHEEP',
    'OTHER',
  ];

  // Animal Genders
  static const List<String> animalGenders = [
    'MALE',
    'FEMALE',
  ];

  // User Roles
  static const List<String> userRoles = [
    'ADMIN',
    'HR_MANAGER',
    'EMPLOYEE_TRADER',
  ];

  // Trade Status
  static const List<String> tradeStatus = [
    'PENDING',
    'LISTED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'FAILED',
  ];

  // Currency Types
  static const List<String> currencies = ['HBAR', 'ZAU'];
}
