import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
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
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _apiClient.register(request);

      if (response.success && response.data != null) {
        // Store tokens
        await StorageService.setAccessToken(response.data!.accessToken);
        await StorageService.setRefreshToken(response.data!.refreshToken);

        // Store user data
        final userModel = UserModel(
          id: response.data!.user.id,
          email: response.data!.user.email,
          firstName: response.data!.user.firstName,
          lastName: response.data!.user.lastName,
          role: response.data!.user.role,
          isVerified: response.data!.user.isVerified,
          lastLoginAt: response.data!.user.lastLoginAt,
        );
        await StorageService.setUserData(userModel);

        return response.data!;
      } else {
        throw Exception(response.message);
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
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.login(request);

      if (response.success && response.data != null) {
        // Store tokens
        await StorageService.setAccessToken(response.data!.accessToken);
        await StorageService.setRefreshToken(response.data!.refreshToken);

        // Store user data
        final userModel = UserModel(
          id: response.data!.user.id,
          email: response.data!.user.email,
          firstName: response.data!.user.firstName,
          lastName: response.data!.user.lastName,
          role: response.data!.user.role,
          isVerified: response.data!.user.isVerified,
          lastLoginAt: response.data!.user.lastLoginAt,
        );
        await StorageService.setUserData(userModel);

        return response.data!;
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await StorageService.clearTokens();
      await StorageService.clearUserData();
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
