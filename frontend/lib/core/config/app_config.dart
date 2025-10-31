import 'environment.dart';

class AppConfig {
  // App Information
  static const String appName = 'Zauro Marketplace';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Blockchain-based Animal Trading Platform';

  // API Configuration
  static const String apiPrefix = '/api/v1';
  static String get fullApiUrl => '${EnvironmentConfig.apiBaseUrl}$apiPrefix';

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
  static const String didEndpoint = '/did';
  static const String adminCollectionsEndpoint = '/admin/collections';

  // Auth Endpoints
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh';
  static const String forgotPasswordRequestEndpoint =
      '$authEndpoint/forgot-password/request';
  static const String forgotPasswordVerifyEndpoint =
      '$authEndpoint/forgot-password/verify';
  static const String forgotPasswordResetEndpoint =
      '$authEndpoint/forgot-password/reset';
  static const String profileEndpoint = '$authEndpoint/profile';

  // Wallet Endpoints
  static const String createWalletEndpoint = '$walletsEndpoint/create';
  static const String myWalletEndpoint = '$walletsEndpoint/my-wallet';
  static const String myWalletBalanceEndpoint =
      '$walletsEndpoint/my-wallet/balance';
  static const String transferHbarEndpoint = '$walletsEndpoint/transfer/hbar';
  static const String fundMyAccountEndpoint =
      '$walletsEndpoint/fund/my-account';
  static const String fundAccountEndpoint = '$walletsEndpoint/fund/account';
  static const String createWalletWithBalanceEndpoint =
      '$walletsEndpoint/create-with-balance';

  // Animal Endpoints
  static const String createAnimalEndpoint = '$animalsEndpoint';
  static const String getAnimalsEndpoint = '$animalsEndpoint';

  // Trading Endpoints
  static const String listTradeEndpoint = '$tradesEndpoint/list';
  static const String getTradesEndpoint = '$tradesEndpoint';

  // DID Endpoints
  static const String myDidEndpoint = '$didEndpoint/my-did';
  static const String createDidEndpoint = '$didEndpoint/create';
  static const String credentialsEndpoint = '$didEndpoint/credentials';
  static const String issueKycCredentialEndpoint =
      '$didEndpoint/credentials/issue/kyc';
  static const String issueReputationCredentialEndpoint =
      '$didEndpoint/credentials/issue/reputation';
  static const String issueVeterinaryCredentialEndpoint =
      '$didEndpoint/credentials/issue/veterinary';
  static const String verifyCredentialEndpoint =
      '$didEndpoint/credentials/verify';

  // Admin Collection Endpoints
  static const String createCollectionEndpoint = '$adminCollectionsEndpoint';
  static const String listCollectionsEndpoint = '$adminCollectionsEndpoint';
  static const String defaultCollectionEndpoint =
      '$adminCollectionsEndpoint/default';
  static const String rotateCollectionEndpoint =
      '$adminCollectionsEndpoint/rotate-if-full';

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

  // Animal Species (matching backend AnimalSpecies enum)
  static const List<String> animalSpecies = [
    'COW',
    'GOAT',
    'SHEEP',
  ];

  // Animal Status (matching backend AnimalStatus enum)
  static const List<String> animalStatuses = [
    'PENDING_EXPERT_REVIEW',
    'EXPERT_APPROVED',
    'EXPERT_REJECTED',
    'LISTED',
    'MINTED',
  ];

  // Animal Genders
  static const List<String> animalGenders = [
    'MALE',
    'FEMALE',
  ];

  // User Roles (matching backend UserRole enum)
  static const List<String> userRoles = [
    'EMPLOYEE_TRADER',
    'ADMIN',
  ];

  // Trade Status (matching backend TradeStatus enum)
  static const List<String> tradeStatus = [
    'PENDING',
    'LISTED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
  ];

  // Credential Types
  static const List<String> credentialTypes = [
    'KYC',
    'REPUTATION',
    'VETERINARY',
  ];

  // Credential Status (matching backend CredentialStatus enum)
  static const List<String> credentialStatuses = [
    'ACTIVE',
    'REVOKED',
    'EXPIRED',
    'PENDING',
  ];

  // Collection Status
  static const List<String> collectionStatuses = [
    'ACTIVE',
    'DISABLED',
  ];

  // Currency Types
  static const List<String> currencies = ['HBAR', 'ZAU'];
}
