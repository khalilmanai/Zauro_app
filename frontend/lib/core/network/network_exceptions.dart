import 'package:dio/dio.dart';

/// Custom exception class for network-related errors
/// Provides detailed error information and user-friendly messages
class NetworkException implements Exception {
  final String message;
  final String? prefix;
  final int? statusCode;
  final dynamic data;

  const NetworkException({
    required this.message,
    this.prefix,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    if (prefix != null) {
      return '$prefix: $message';
    }
    return message;
  }

  /// Convert DioException to NetworkException with detailed error information
  factory NetworkException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          prefix: 'Connection Timeout',
        );

      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message: 'Request timeout. The server is taking too long to respond.',
          prefix: 'Send Timeout',
        );

      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message:
              'Response timeout. The server is taking too long to respond.',
          prefix: 'Receive Timeout',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Invalid SSL certificate. Connection is not secure.',
          prefix: 'SSL Error',
        );

      case DioExceptionType.badResponse:
        return NetworkException._handleBadResponse(error);

      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
          prefix: 'Request Cancelled',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
          prefix: 'Connection Error',
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return const NetworkException(
            message: 'No internet connection. Please check your network.',
            prefix: 'Network Error',
          );
        }
        return NetworkException(
          message: error.message ?? 'An unexpected error occurred.',
          prefix: 'Unknown Error',
        );
    }
  }

  /// Handle HTTP error responses with appropriate messages
  static NetworkException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract error message from response if available
    String message = 'An error occurred while processing your request.';

    if (data is Map<String, dynamic>) {
      // Try different common error message fields
      message = data['message'] ??
          data['error'] ??
          data['errors']?.toString() ??
          message;
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return NetworkException(
          message: message,
          prefix: 'Bad Request',
          statusCode: 400,
          data: data,
        );

      case 401:
        return NetworkException(
          message: 'Authentication failed. Please login again.',
          prefix: 'Unauthorized',
          statusCode: 401,
          data: data,
        );

      case 403:
        return NetworkException(
          message: 'You do not have permission to access this resource.',
          prefix: 'Forbidden',
          statusCode: 403,
          data: data,
        );

      case 404:
        return NetworkException(
          message: 'The requested resource was not found.',
          prefix: 'Not Found',
          statusCode: 404,
          data: data,
        );

      case 409:
        return NetworkException(
          message: message,
          prefix: 'Conflict',
          statusCode: 409,
          data: data,
        );

      case 422:
        return NetworkException(
          message: message,
          prefix: 'Validation Error',
          statusCode: 422,
          data: data,
        );

      case 500:
        return const NetworkException(
          message: 'Internal server error. Please try again later.',
          prefix: 'Server Error',
          statusCode: 500,
        );

      case 503:
        return const NetworkException(
          message: 'Service unavailable. Please try again later.',
          prefix: 'Service Unavailable',
          statusCode: 503,
        );

      default:
        return NetworkException(
          message: message,
          prefix: 'HTTP Error $statusCode',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Check if the error is related to authentication
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Check if the error is a validation error
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  /// Check if the error is a server error
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Check if the error is a client error
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Get user-friendly error message
  String get userMessage {
    if (isServerError) {
      return 'Something went wrong on our end. Please try again later.';
    }
    if (statusCode == 401) {
      return 'Your session has expired. Please login again.';
    }
    return message;
  }
}

/// Legacy support - will be deprecated
@Deprecated('Use NetworkException instead')
class NetworkExceptions implements Exception {
  final String message;
  NetworkExceptions(this.message);

  static NetworkExceptions getDioException(dynamic error) {
    if (error is DioException) {
      final networkError = NetworkException.fromDioException(error);
      return NetworkExceptions(networkError.message);
    }
    return NetworkExceptions(error.toString());
  }

  static NetworkExceptions noInternetConnection() {
    return NetworkExceptions('No Internet Connection');
  }
}
