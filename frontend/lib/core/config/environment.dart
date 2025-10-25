import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get current {
    if (kReleaseMode) {
      return Environment.production;
    } else if (kProfileMode) {
      return Environment.staging;
    } else {
      return Environment.development;
    }
  }

  static String get name {
    switch (current) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  static bool get isProduction => current == Environment.production;
  static bool get isStaging => current == Environment.staging;
  static bool get isDevelopment => current == Environment.development;

  // API Configuration
  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return const String.fromEnvironment(
          'DEV_API_URL',
          defaultValue: 'http://10.0.2.2:3000',
        );
      case Environment.staging:
        return const String.fromEnvironment(
          'STAGING_API_URL',
          defaultValue: 'https://staging-api.zauro.com',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'PROD_API_URL',
          defaultValue: 'https://api.zauro.com',
        );
    }
  }

  // Feature Flags
  static bool get enableAnalytics => !isDevelopment;
  static bool get enableCrashReporting => !isDevelopment;
  static bool get enablePerformanceMonitoring => !isDevelopment;
  static bool get enableDebugLogging => isDevelopment;
  static bool get enableNetworkLogging => isDevelopment || isStaging;

  // Security Configuration
  static bool get enableCertificatePinning => isProduction;
  static bool get enableCodeObfuscation => isProduction;
  static Duration get authTokenExpiration =>
      isProduction ? const Duration(hours: 1) : const Duration(hours: 24);

  // Performance Configuration
  static int get maxImageCacheSize => isProduction ? 100 : 200; // MB
  static Duration get networkTimeout =>
      isProduction ? const Duration(seconds: 30) : const Duration(seconds: 60);

  // Debug Configuration
  static bool get showDebugBanner => isDevelopment;
  static bool get showPerformanceOverlay =>
      isDevelopment &&
      const bool.fromEnvironment('SHOW_PERFORMANCE_OVERLAY',
          defaultValue: false);

  // App Store Configuration
  static String get appStoreId => const String.fromEnvironment(
        'APP_STORE_ID',
        defaultValue: 'com.zauro.marketplace',
      );

  static String get playStoreId => const String.fromEnvironment(
        'PLAY_STORE_ID',
        defaultValue: 'com.zauro.marketplace',
      );

  // External Service Keys (should be injected via environment variables)
  static String get firebaseApiKey =>
      const String.fromEnvironment('FIREBASE_API_KEY');
  static String get crashlyticsApiKey =>
      const String.fromEnvironment('CRASHLYTICS_API_KEY');
  static String get analyticsTrackingId =>
      const String.fromEnvironment('ANALYTICS_TRACKING_ID');

  // Database Configuration
  static String get hiveBoxEncryptionKey => const String.fromEnvironment(
        'HIVE_ENCRYPTION_KEY',
        defaultValue: 'zauro_default_key_change_in_production',
      );

  // Validation
  static void validateConfiguration() {
    final errors = <String>[];

    if (isProduction) {
      if (firebaseApiKey.isEmpty) {
        errors.add('FIREBASE_API_KEY is required for production');
      }
      if (hiveBoxEncryptionKey == 'zauro_default_key_change_in_production') {
        errors.add('HIVE_ENCRYPTION_KEY must be changed for production');
      }
      if (apiBaseUrl.contains('localhost') || apiBaseUrl.contains('192.168')) {
        errors.add(
            'Production API URL should not point to local/development server');
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(
          'Environment configuration errors:\n${errors.join('\n')}');
    }
  }

  // Get configuration summary
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': name,
      'apiBaseUrl': apiBaseUrl,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enableDebugLogging': enableDebugLogging,
      'appStoreId': appStoreId,
      'buildMode': kDebugMode
          ? 'debug'
          : kProfileMode
              ? 'profile'
              : 'release',
    };
  }
}
