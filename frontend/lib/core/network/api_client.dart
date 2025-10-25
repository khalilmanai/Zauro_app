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

part 'api_client.g.dart';

// Dio Provider
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
    ),
  );

  // Add interceptors
  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(ResponseTransformInterceptor());
  // Only add logging in debug mode
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
  }

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
  Future<ApiResponse<PaginatedResponse<Animal>>> getAnimals(
    @Query('page') int page,
    @Query('limit') int limit,
    @Query('ownerId') String? ownerId,
  );

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
  Future<ApiResponse<WalletResponse>> createWallet(
      @Body() CreateWalletRequest request);

  @GET('/wallets/my-wallet')
  Future<ApiResponse<WalletResponse>> getMyWallet();

  @GET('/wallets/my-wallet/balance')
  Future<ApiResponse<WalletBalance>> getMyWalletBalance();

  @POST('/wallets/transfer/hbar')
  Future<ApiResponse<TransferResponse>> transferHbar(
      @Body() TransferHbarRequest request);

  @GET('/wallets/{id}')
  Future<ApiResponse<WalletResponse>> getWallet(@Path('id') String id);

  @GET('/wallets/{id}/balance')
  Future<ApiResponse<WalletBalance>> getWalletBalance(@Path('id') String id);

  @POST('/wallets/fund/my-account')
  Future<ApiResponse<TransferResponse>> fundMyAccount(
      @Body() FundAccountRequest request);

  @POST('/wallets/fund/account')
  Future<ApiResponse<TransferResponse>> fundAccount(
      @Body() FundAccountRequest request);

  @POST('/wallets/create-with-balance')
  Future<ApiResponse<WalletResponse>> createWalletWithBalance(
      @Body() FundAccountRequest request);
}

// Response Transform Interceptor
class ResponseTransformInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Transform direct auth responses to ApiResponse format
    if (response.requestOptions.path.contains('/auth/') &&
        response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;

      // Check if response is already in ApiResponse format
      if (!data.containsKey('success') && !data.containsKey('message')) {
        // Check if it's an auth response (has accessToken and user)
        if (data.containsKey('accessToken') && data.containsKey('user')) {
          // Transform to ApiResponse format
          response.data = {
            'success': true,
            'message': 'Authentication successful',
            'data': data,
            'timestamp': DateTime.now().toIso8601String(),
          };
        }
      }
    }

    handler.next(response);
  }
}

// Auth Interceptor
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: AppConfig.fullApiUrl));
          dio.options.headers['Authorization'] = 'Bearer $refreshToken';

          final response = await dio.post('/auth/refresh');
          final newToken = response.data['data']['accessToken'];

          await StorageService.setAccessToken(newToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          // Refresh failed, logout user
          await StorageService.clearTokens();
        }
      }
    }
    handler.next(err);
  }
}

// Generic API Response Model
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
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

// Paginated Response Model
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationInfo pagination;

  PaginatedResponse({required this.data, required this.pagination});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List?)?.map((e) => fromJsonT(e)).toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
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
}

// Message Response Model
class MessageResponse {
  final String message;

  MessageResponse({required this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(message: json['message'] ?? '');
  }
}
