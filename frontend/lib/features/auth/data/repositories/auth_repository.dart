import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/storage_service.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  // Register new user
  Future<AuthResponse> register({
    required String email,
    String? phone,
    required String password,
    required String firstName,
    required String lastName,
    String? country,
  }) async {
    try {
      // Validate phone (if provided) to avoid backend 400
      if (phone != null && phone.isNotEmpty) {
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
        if (!phoneRegex.hasMatch(phone)) {
          throw Exception('Please enter a valid phone number');
        }
      }

      // Build payload and intentionally omit avatarUrl because backend validation
      // rejects the presence of that property on register requests.
      final Map<String, dynamic> payload = {
        'email': email,
        'phone': phone?.isNotEmpty == true ? phone : null,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
      };
      // remove null values
      payload.removeWhere((k, v) => v == null);

      // Use the underlying Dio instance from the generated ApiClient to send a raw request
      // We now expose a typed getter on ApiClient via a library-scoped extension
      // (see `api_client.dart`) so we can safely access the Dio instance.
      final dio = _apiClient.dio;
      final rawResp = await dio.post('/auth/register', data: payload);

      // Normalize response: backend might return either direct auth object or ApiResponse wrapper
      final Map<String, dynamic> respData = (rawResp.data is Map)
          ? Map<String, dynamic>.from(rawResp.data)
          : {'data': rawResp.data};
      Map<String, dynamic> apiMap;
      if (respData.containsKey('success') || respData.containsKey('message')) {
        apiMap = respData;
      } else if (respData.containsKey('accessToken') &&
          respData.containsKey('user')) {
        apiMap = {
          'success': true,
          'message': 'Authentication successful',
          'data': respData,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        apiMap = {
          'success': false,
          'message': 'Unexpected response',
          'timestamp': DateTime.now().toIso8601String()
        };
      }

      final apiResponse = ApiResponse.fromJson(apiMap,
          (json) => AuthResponse.fromJson(json as Map<String, dynamic>));

      if (apiResponse.success && apiResponse.data != null) {
        final response = apiResponse.data!;
        // Store tokens
        await StorageService.setAccessToken(response.accessToken);
        await StorageService.setRefreshToken(response.refreshToken);

        // Store user data
        final userModel = UserModel(
          id: response.user.id,
          email: response.user.email,
          firstName: response.user.firstName,
          lastName: response.user.lastName,
          role: response.user.role,
          isVerified: response.user.isVerified,
          lastLoginAt: response.user.lastLoginAt,
          country: response.user.country,
        );
        await StorageService.setUserData(userModel);

        return response;
      } else {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      // Use raw dio to tolerate wrapped/unwrapped payloads
      final dio = _apiClient.dio;
      final rawResp = await dio.post('/auth/login', data: request.toJson());

      // Normalize response
      final Map<String, dynamic> respData = (rawResp.data is Map)
          ? Map<String, dynamic>.from(rawResp.data)
          : {'data': rawResp.data};
      Map<String, dynamic> apiMap;
      if (respData.containsKey('success') || respData.containsKey('message')) {
        apiMap = respData;
      } else if (respData.containsKey('accessToken') && respData.containsKey('user')) {
        apiMap = {
          'success': true,
          'message': 'Authentication successful',
          'data': respData,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        apiMap = {
          'success': false,
          'message': 'Unexpected response',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      final apiResponse = ApiResponse.fromJson(
        apiMap,
        (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        final auth = apiResponse.data!;
        await StorageService.setAccessToken(auth.accessToken);
        await StorageService.setRefreshToken(auth.refreshToken);

        final userModel = UserModel(
          id: auth.user.id,
          email: auth.user.email,
          firstName: auth.user.firstName,
          lastName: auth.user.lastName,
          role: auth.user.role,
          isVerified: auth.user.isVerified,
          lastLoginAt: auth.user.lastLoginAt,
          country: auth.user.country,
        );
        await StorageService.setUserData(userModel);

        await StorageService.setRememberMe(rememberMe);
        if (rememberMe) {
          await StorageService.setRememberMeCredentials(email, password);
        } else {
          await StorageService.clearRememberedCredentials();
        }

        return auth;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Verify password without mutating global auth/session state
  /// Returns true if credentials are valid, false otherwise
  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Use a fresh Dio to avoid interceptors/state side effects
      final dio = Dio(BaseOptions(baseUrl: AppConfig.fullApiUrl));
      final payload = {
        'email': email,
        'password': password,
      };
      final response = await dio.post('/auth/login', data: payload);

      // Consider 200 as success with either wrapped or unwrapped payload
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('success')) {
            return data['success'] == true;
          }
          // Unwrapped response with tokens
          if (data.containsKey('accessToken') && data.containsKey('user')) {
            return true;
          }
        }
      }

      return false;
    } on DioException catch (e) {
      // Treat invalid credentials as false; only throw for non-auth errors
      final status = e.response?.statusCode;
      if (status == 400 || status == 401) return false;
      throw _handleDioError(e);
    } catch (e) {
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await StorageService.clearTokens();
      await StorageService.clearUserData();
      await StorageService.clearRememberedCredentials();
      await StorageService.setRememberMe(false);
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.getProfile();

      if (response.success && response.data != null) {
        return response.data!;
      }
      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      return null;
    }
  }

  // Update current user profile (best-effort; backend may not support yet)
  Future<User?> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? country,
    String? avatarUrl,
  }) async {
    try {
      final dio = _apiClient.dio;
      final payload = <String, dynamic>{
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (country != null) 'country': country,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
      if (payload.isEmpty) return await getCurrentUser();

      // Assume PATCH /auth/profile; tolerate wrapped or unwrapped
      final res = await dio.patch('/auth/profile', data: payload);
      final data = res.data;

      Map<String, dynamic>? userMap;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          userMap = (data['data'] as Map<String, dynamic>);
        } else if (data.containsKey('id') && data.containsKey('email')) {
          userMap = data;
        }
      }

      if (userMap != null) {
        final user = User.fromJson(userMap);
        // Persist minimal local cache
        await StorageService.setUserData(UserModel(
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          isVerified: user.isVerified,
          lastLoginAt: user.lastLoginAt,
          country: user.country,
        ));
        return user;
      }

      // Fallback: refetch profile
      return await getCurrentUser();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null) return false;

      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Get stored user data
  UserModel? getStoredUser() {
    return StorageService.getUserData();
  }

  // Refresh token
  Future<String> refreshToken() async {
    try {
      final response = await _apiClient.refreshToken();

      if (response.success && response.data != null) {
        await StorageService.setAccessToken(response.data!.accessToken);
        return response.data!.accessToken;
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Forgot password request
  Future<String> forgotPasswordRequest({String? email, String? phone}) async {
    try {
      final request = ForgotPasswordRequest(email: email, phone: phone);
      final response = await _apiClient.forgotPasswordRequest(request);

      if (response.success && response.data != null) {
        return response.data!.message;
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Password reset request failed: ${e.toString()}');
    }
  }

  // Verify OTP
  Future<String> verifyOtp({
    required String code,
    String? email,
    String? phone,
  }) async {
    try {
      final request = VerifyOtpRequest(code: code, email: email, phone: phone);
      final response = await _apiClient.verifyOtp(request);

      if (response.success && response.data != null) {
        return response.data!.message;
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  // Reset password
  Future<String> resetPassword({
    required String code,
    required String newPassword,
    String? email,
    String? phone,
  }) async {
    try {
      final request = ResetPasswordRequest(
        code: code,
        newPassword: newPassword,
        email: email,
        phone: phone,
      );
      final response = await _apiClient.resetPassword(request);

      if (response.success && response.data != null) {
        return response.data!.message;
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Handle Dio errors
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'An error occurred';

        switch (statusCode) {
          case 400:
            return Exception('Bad request: $message');
          case 401:
            return Exception('Invalid credentials');
          case 403:
            return Exception('Access denied');
          case 404:
            return Exception('Resource not found');
          case 409:
            return Exception('User already exists');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception(message);
        }

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      case DioExceptionType.unknown:
        return Exception(
          'Network error. Please check your internet connection.',
        );

      default:
        return Exception('An unexpected error occurred');
    }
  }
}
