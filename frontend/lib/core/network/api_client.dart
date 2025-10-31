import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../config/app_config.dart';
import '../utils/storage_service.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/animals/data/models/animal_models.dart';
import '../../features/trading/data/models/trade_models.dart';
import '../../features/wallet/data/models/wallet_models.dart';
import '../../features/did/data/models/did_models.dart';
import '../../features/admin/data/models/collection_models.dart';
import 'network_exceptions.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_client.g.dart';

/// Provider for Dio HTTP client with configured interceptors
/// Includes authentication, response transformation, retry logic, and logging
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.fullApiUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Validate status codes
      validateStatus: (status) {
        // Accept 200-299 status codes
        return status != null && status >= 200 && status < 300;
      },
    ),
  );

  // Add interceptors in order of execution
  // 1. Request logging (debug only)
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) {
          debugPrint('🌐 [API] $object');
        },
      ),
    );
  }

  // 2. Authentication token injection
  dio.interceptors.add(AuthInterceptor());

  // 3. Response transformation
  dio.interceptors.add(ResponseTransformInterceptor());

  // 4. Retry logic for network failures
  dio.interceptors.add(RetryInterceptor(dio: dio));

  // 5. Error handling and transformation
  dio.interceptors.add(ErrorHandlerInterceptor());

  return dio;
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

  // Auth Endpoints
  @POST('/auth/register')
  Future<ApiResponse<AuthResponse>> register(@Body() RegisterRequest request);

  @POST('/auth/login')
  Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);

  @POST('/auth/refresh')
  Future<ApiResponse<RefreshTokenResponse>> refreshToken();

  @POST('/auth/forgot-password/request')
  Future<ApiResponse<MessageResponse>> forgotPasswordRequest(
    @Body() ForgotPasswordRequest request,
  );

  @POST('/auth/forgot-password/verify')
  Future<ApiResponse<MessageResponse>> verifyOtp(
    @Body() VerifyOtpRequest request,
  );

  @POST('/auth/forgot-password/reset')
  Future<ApiResponse<MessageResponse>> resetPassword(
    @Body() ResetPasswordRequest request,
  );

  @GET('/auth/profile')
  Future<ApiResponse<User>> getProfile();

  // Animals Endpoints
  @POST('/animals')
  Future<ApiResponse<Animal>> createAnimal(@Body() CreateAnimalRequest request);

  @GET('/animals')
  Future<HttpResponse<dynamic>> getAnimals(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('ownerId') String? ownerId,
  );

  // My Animals (authenticated user's animals)
  @GET('/animals/my')
  Future<HttpResponse<dynamic>> getMyAnimals(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/animals/pending-review')
  Future<ApiResponse<PaginatedResponse<Animal>>> getPendingReviewAnimals(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @PUT('/animals/{id}/review')
  Future<ApiResponse<Animal>> reviewAnimal(
    @Path('id') String id,
    @Body() ReviewAnimalRequest request,
  );

  @POST('/animals/{id}/mint')
  Future<ApiResponse<Animal>> mintAnimal(@Path('id') String id);

  @GET('/animals/{id}')
  Future<ApiResponse<Animal>> getAnimal(@Path('id') String id);

  @PATCH('/animals/{id}')
  Future<ApiResponse<Animal>> updateAnimal(
    @Path('id') String id,
    @Body() UpdateAnimalRequest request,
  );

  @DELETE('/animals/{id}')
  Future<ApiResponse<MessageResponse>> deleteAnimal(@Path('id') String id);

  // Trading Endpoints
  @POST('/trades/list')
  Future<ApiResponse<Trade>> createTrade(@Body() CreateTradeRequest request);

  @GET('/trades')
  Future<ApiResponse<PaginatedResponse<Trade>>> getTrades(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('status') String? status,
  );

  @GET('/trades/{id}')
  Future<ApiResponse<Trade>> getTrade(@Path('id') String id);

  @POST('/trades/buy/{id}')
  Future<ApiResponse<Trade>> buyAnimal(@Path('id') String id);

  @POST('/trades/execute/{id}')
  Future<ApiResponse<Trade>> executeTrade(@Path('id') String id);

  @POST('/trades/cancel/{id}')
  Future<ApiResponse<Trade>> cancelTrade(@Path('id') String id);

  // Wallet Endpoints
  @POST('/wallets/create')
  Future<ApiResponse<Wallet>> createWallet(
      @Body() CreateWalletRequest request);

  @GET('/wallets/my-wallet')
  Future<Wallet> getMyWallet();

  // Note: This endpoint returns data directly, not wrapped in ApiResponse
  // Using raw Map to get JSON directly
  @GET('/wallets/my-wallet/balance')
  Future<WalletBalance> getMyWalletBalanceRaw();

  /// Get wallet by ID
  @GET('/wallets/{id}')
  Future<ApiResponse<Wallet>> getWallet(@Path('id') String id);

  /// Get wallet balance by ID - returns data directly
  @GET('/wallets/{id}/balance')
  Future<WalletBalance> getWalletBalanceRaw(@Path('id') String id);

  /// Transfer HBAR to another account
  @POST('/wallets/transfer/hbar')
  Future<ApiResponse<TransferResponse>> transferHbar(
    @Body() TransferHbarRequest request,
  );

  /// Fund my account
  @POST('/wallets/fund/my-account')
  Future<ApiResponse<TransferResponse>> fundMyAccount(
    @Body() FundAccountRequest request,
  );

  /// Fund any account
  @POST('/wallets/fund/account')
  Future<ApiResponse<TransferResponse>> fundAccount(
    @Body() FundAccountRequest request,
  );

  /// Create wallet with balance
  @POST('/wallets/create-with-balance')
  Future<ApiResponse<Wallet>> createWalletWithBalance(
    @Body() FundAccountRequest request,
  );

  // DID Endpoints
  @GET('/did/my-did')
  Future<ApiResponse<DidResponse>> getMyDid();

  @POST('/did/create')
  Future<ApiResponse<DidResponse>> createDid();

  @GET('/did/resolve/{did}')
  Future<ApiResponse<DidResponse>> resolveDid(@Path('did') String did);

  @GET('/did/credentials')
  Future<ApiResponse<CredentialsResponse>> getMyCredentials();

  @GET('/did/credentials/{type}')
  Future<ApiResponse<CredentialsResponse>> getCredentialsByType(
      @Path('type') String type);

  @POST('/did/credentials/issue/kyc')
  Future<ApiResponse<CredentialResponse>> issueKycCredential(
      @Body() IssueKycCredentialRequest request);

  @POST('/did/credentials/issue/reputation')
  Future<ApiResponse<CredentialResponse>> issueReputationCredential(
      @Body() IssueReputationCredentialRequest request);

  @POST('/did/credentials/issue/veterinary')
  Future<ApiResponse<CredentialResponse>> issueVeterinaryCredential(
      @Body() IssueVeterinaryCredentialRequest request);

  @POST('/did/credentials/verify')
  Future<ApiResponse<VerifyCredentialResponse>> verifyCredential(
      @Body() VerifyCredentialRequest request);

  @POST('/did/credentials/revoke/{credentialId}')
  Future<ApiResponse<RevokeCredentialResponse>> revokeCredential(
      @Path('credentialId') String credentialId);

  // Admin Collections
  @POST('/admin/collections')
  Future<ApiResponse<Collection>> createCollection(
      @Body() CreateCollectionRequest request);

  @GET('/admin/collections')
  Future<ApiResponse<List<Collection>>> listCollections();

  @GET('/admin/collections/default')
  Future<ApiResponse<Collection>> getDefaultCollection();

  @POST('/admin/collections/rotate-if-full')
  Future<ApiResponse<Collection>> rotateCollectionsIfFull(
      @Body() RotateCollectionRequest request);

  @PATCH('/admin/collections/{id}/disable')
  Future<ApiResponse<Collection>> disableCollection(@Path('id') String id);

  @PATCH('/admin/collections/{id}/default')
  Future<ApiResponse<Collection>> setCollectionAsDefault(@Path('id') String id);

  // Animal upload endpoints (multipart)
  @MultiPart()
  @POST('/animals/{id}/upload-image')
  Future<ApiResponse<dynamic>> uploadAnimalImage(
    @Path('id') String id,
    @Part(name: 'image') File image,
  );

  @MultiPart()
  @POST('/animals/{id}/upload-vet-record')
  Future<ApiResponse<dynamic>> uploadAnimalVetRecord(
    @Path('id') String id,
    @Part(name: 'vetRecord') File vetRecord,
  );
}

/// Interceptor to transform responses to a consistent format
/// Handles both wrapped (ApiResponse) and unwrapped responses
class ResponseTransformInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Transform auth responses to ApiResponse format
        if (response.requestOptions.path.contains('/auth/')) {
          // Check if response is already in ApiResponse format
          if (!data.containsKey('success') && !data.containsKey('message')) {
            // Check if it's an auth response (has accessToken and user)
            if (data.containsKey('accessToken') && data.containsKey('user')) {
              response.data = {
                'success': true,
                'message': 'Authentication successful',
                'data': data,
                'timestamp': DateTime.now().toIso8601String(),
              };
            } else if (data.containsKey('message')) {
              // Password reset endpoints return just a message
              response.data = {
                'success': true,
                'message': data['message'],
                'data': data,
                'timestamp': DateTime.now().toIso8601String(),
              };
            }
          }
        }

        // Normalize single-animal GET responses that may return raw object
        final path = response.requestOptions.path;
        final method = response.requestOptions.method.toUpperCase();
        final looksLikeRawAnimal =
            data.containsKey('id') && data.containsKey('species');

        if (method == 'GET' && path.contains('/animals/') && looksLikeRawAnimal) {
          response.data = {
            'success': true,
            'message': 'OK',
            'data': data,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          // Add success flag to responses that don't have it
          if (!data.containsKey('success') && response.statusCode == 200) {
            data['success'] = true;
          }
        }
      }

      handler.next(response);
    } catch (e) {
      // If transformation fails, pass original response
      debugPrint('⚠️ Response transformation error: $e');
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add more context to error responses
    if (err.response?.data is Map<String, dynamic>) {
      final data = err.response!.data as Map<String, dynamic>;
      if (!data.containsKey('success')) {
        data['success'] = false;
      }
    }
    handler.next(err);
  }
}

/// Interceptor to handle authentication token injection and refresh
/// Automatically refreshes expired tokens and retries failed requests
class AuthInterceptor extends Interceptor {
  static const int maxRetryAttempts = 1;
  static bool _isRefreshing = false;
  static final List<Function> _refreshCallbacks = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip auth header for public endpoints
      if (_isPublicEndpoint(options.path)) {
        handler.next(options);
        return;
      }

      final token = await StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      debugPrint('❌ Auth interceptor request error: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 errors (unauthorized)
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Skip refresh for login/register endpoints
    if (_isAuthEndpoint(err.requestOptions.path)) {
      await StorageService.clearTokens();
      handler.next(err);
      return;
    }

    debugPrint('🔐 Token expired, attempting refresh...');

    try {
      // If already refreshing, wait for it to complete
      if (_isRefreshing) {
        await _waitForRefresh();
        return _retryRequest(err, handler);
      }

      // Start refresh process
      _isRefreshing = true;
      final refreshToken = await StorageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('❌ No refresh token available');
        await _handleRefreshFailure();
        handler.reject(err);
        return;
      }

      // Attempt token refresh
      final newToken = await _refreshAccessToken(refreshToken);

      if (newToken != null) {
        await StorageService.setAccessToken(newToken);
        debugPrint('✅ Token refreshed successfully');

        // Notify waiting requests
        _notifyRefreshComplete(true);

        // Retry original request with new token
        return _retryRequest(err, handler);
      } else {
        debugPrint('❌ Token refresh failed');
        await _handleRefreshFailure();
        handler.reject(err);
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      await _handleRefreshFailure();
      handler.reject(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Refresh the access token using the refresh token
  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.fullApiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      dio.options.headers['Authorization'] = 'Bearer $refreshToken';

      final response = await dio.post('/auth/refresh');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both wrapped and unwrapped responses
        if (data is Map<String, dynamic>) {
          return data['data']?['accessToken'] ?? data['accessToken'];
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Refresh token request failed: $e');
      return null;
    }
  }

  /// Retry the original request with the new token
  Future<void> _retryRequest(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
      }

      // Create new Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(baseUrl: AppConfig.fullApiUrl));
      final response = await dio.fetch(err.requestOptions);

      handler.resolve(response);
    } catch (e) {
      debugPrint('❌ Retry request failed: $e');
      handler.reject(err);
    }
  }

  /// Handle refresh token failure - clear tokens and navigate to login
  Future<void> _handleRefreshFailure() async {
    await StorageService.clearTokens();
    _notifyRefreshComplete(false);
    // TODO: Navigate to login screen
    // You can use a global navigation key or event bus here
  }

  /// Wait for ongoing refresh to complete
  Future<void> _waitForRefresh() async {
    final completer = Completer<void>();
    _refreshCallbacks.add(() => completer.complete());
    await completer.future;
  }

  /// Notify waiting requests that refresh is complete
  void _notifyRefreshComplete(bool success) {
    for (final callback in _refreshCallbacks) {
      callback();
    }
    _refreshCallbacks.clear();
  }

  /// Check if endpoint is public (doesn't require authentication)
  bool _isPublicEndpoint(String path) {
    // Be precise: only specific endpoints are public.
    // Do NOT use substring matches that could include protected routes like /animals/{id}.
    if (path == '/auth/register' || path == '/auth/login') {
      return true;
    }

    // All forgot-password subpaths are public
    if (path.startsWith('/auth/forgot-password')) {
      return true;
    }

    // Public list endpoints (no path params)
    if (path == '/animals') {
      return true;
    }

    if (path == '/trades') {
      return true;
    }

    if (path == '/admin/collections/default') {
      return true;
    }

    return false;
  }

  /// Check if endpoint is an auth endpoint (login/register)
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || path.contains('/auth/register');
  }
}

/// Interceptor to retry failed requests due to network issues
/// Implements exponential backoff strategy
class RetryInterceptor extends Interceptor {
  final Dio dio;
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);

  RetryInterceptor({required this.dio});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on specific error types
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      debugPrint('❌ Max retry attempts ($maxRetries) reached');
      handler.next(err);
      return;
    }

    // Calculate delay with exponential backoff
    final delay = initialDelay * (retryCount + 1);
    debugPrint(
        '🔄 Retrying request (${retryCount + 1}/$maxRetries) after ${delay.inMilliseconds}ms...');

    await Future.delayed(delay);

    // Increment retry count
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      // Retry the request
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  /// Determine if the request should be retried
  bool _shouldRetry(DioException err) {
    // Don't retry client errors (4xx) except 408 (timeout) and 429 (rate limit)
    if (err.response?.statusCode != null) {
      final statusCode = err.response!.statusCode!;
      if (statusCode >= 400 && statusCode < 500) {
        return statusCode == 408 || statusCode == 429;
      }
    }

    // Retry on network errors
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }
}

/// Interceptor to handle and transform errors into NetworkException
/// Provides consistent error handling across the app
class ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Transform DioException to NetworkException for better error messages
    final networkException = NetworkException.fromDioException(err);

    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('❌ [API Error] ${networkException.toString()}');
      debugPrint('   Status Code: ${networkException.statusCode}');
      debugPrint('   Path: ${err.requestOptions.path}');
      debugPrint('   Method: ${err.requestOptions.method}');
    }

    // You can add analytics logging here
    // _logErrorToAnalytics(networkException, err);

    // Pass the original error along
    handler.next(err);
  }

  /// Log error to analytics service (optional)
  // void _logErrorToAnalytics(NetworkException exception, DioException err) {
  //   // Example: Firebase Analytics, Sentry, etc.
  //   // FirebaseAnalytics.instance.logEvent(
  //   //   name: 'api_error',
  //   //   parameters: {
  //   //     'endpoint': err.requestOptions.path,
  //   //     'status_code': exception.statusCode?.toString() ?? 'unknown',
  //   //     'error_message': exception.message,
  //   //   },
  //   // );
  // }
}

// Generic API Response Model
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String timestamp;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        timestamp: json['timestamp'] ?? '',
      );

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
        'success': success,
        'message': message,
        'data': data == null ? null : toJsonT(data as T),
        'timestamp': timestamp,
      };
}

// Paginated Response Model
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationInfo pagination;

  PaginatedResponse({required this.data, required this.pagination});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => PaginatedResponse<T>(
        data:
            (json['data'] as List?)?.map((e) => fromJsonT(e)).toList() ?? [],
        pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
      );

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
        'data': data.map((e) => toJsonT(e)).toList(),
        'pagination': pagination.toJson(),
      };
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      };
}

// Message Response Model
class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(message: json['message'] ?? '');
  }
}

// Expose the underlying Dio instance used by the generated ApiClient.
// The generated implementation `_ApiClient` stores a private `_dio` field
// in the same library (this file uses `part 'api_client.g.dart'`), so a
// small library-scoped extension can safely expose it without modifying
// the generated code. This keeps the accessor stable across codegen runs.
extension ApiClientDioAccessor on ApiClient {
  Dio get dio => (this as _ApiClient)._dio;
}
