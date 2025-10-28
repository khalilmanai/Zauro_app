import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'network_exceptions.dart';

/// Utility service for network operations and connectivity checks
/// This class provides helper methods for common network operations
///
/// Note: For most API calls, use the ApiClient from api_client.dart instead.
/// This service is primarily used for:
/// - Connectivity checks
/// - Direct HTTP requests without Retrofit
/// - Network status monitoring
@Deprecated(
    'Use ApiClient from api_client.dart for API calls. This class is kept for backward compatibility.')
class ApiService {
  final Dio _dio;
  final String baseUrl;

  ApiService({required this.baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          responseBody: true,
          requestBody: true,
          logPrint: (object) => debugPrint('[ApiService] $object'),
        ),
      );
    }
  }

  /// Perform a GET request with connectivity check
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.get(
        endpoint,
        queryParameters: params,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: ${e.toString()}',
        prefix: 'Error',
      );
    }
  }

  /// Perform a POST request with connectivity check
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: ${e.toString()}',
        prefix: 'Error',
      );
    }
  }

  /// Perform a PUT request with connectivity check
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: ${e.toString()}',
        prefix: 'Error',
      );
    }
  }

  /// Perform a PATCH request with connectivity check
  Future<Response> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: ${e.toString()}',
        prefix: 'Error',
      );
    }
  }

  /// Perform a DELETE request with connectivity check
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } catch (e) {
      throw NetworkException(
        message: 'Unexpected error: ${e.toString()}',
        prefix: 'Error',
      );
    }
  }

  /// Check internet connectivity before making requests
  Future<void> _checkConnectivity() async {
    try {
      // connectivity_plus returns List<ConnectivityResult>
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult.isEmpty ||
          connectivityResult.contains(ConnectivityResult.none)) {
        throw const NetworkException(
          message: 'No internet connection. Please check your network.',
          prefix: 'Connection Error',
        );
      }
    } catch (e) {
      if (e is NetworkException) rethrow;
      // If connectivity check fails, proceed anyway (don't block the request)
      debugPrint('⚠️ Connectivity check failed: $e');
    }
  }

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      // connectivity_plus returns List<ConnectivityResult>
      final connectivityResult = await Connectivity().checkConnectivity();

      return connectivityResult.isNotEmpty &&
          !connectivityResult.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('⚠️ Error checking connectivity: $e');
      return true; // Assume connected if check fails
    }
  }

  /// Get current network status (returns all available connection types)
  static Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      // connectivity_plus returns List<ConnectivityResult>
      return await Connectivity().checkConnectivity();
    } catch (e) {
      debugPrint('⚠️ Error getting connectivity status: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Stream of connectivity changes
  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged;
  }

  /// Dispose resources
  void dispose() {
    _dio.close(force: true);
  }
}
