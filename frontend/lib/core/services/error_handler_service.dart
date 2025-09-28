import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../errors/failures.dart';

class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  /// Handle Dio exceptions and convert them to user-friendly messages
  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkFailure(
            message:
                'Connection timeout. Please check your internet connection.');
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(
            message: 'Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
            message: 'Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request was cancelled.');
      case DioExceptionType.connectionError:
        return const NetworkFailure(
            message:
                'No internet connection. Please check your network settings.');
      default:
        return const NetworkFailure(
            message: 'An unexpected error occurred. Please try again.');
    }
  }

  /// Handle HTTP response errors
  static Failure _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    // Try to extract error message from response
    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(
            message: message.isNotEmpty ? message : 'Invalid request data.');
      case 401:
        return AuthenticationFailure(
            message: message.isNotEmpty
                ? message
                : 'Authentication failed. Please login again.');
      case 403:
        return AuthenticationFailure(
            message: message.isNotEmpty
                ? message
                : 'Access denied. You don\'t have permission.');
      case 404:
        return ServerFailure(
            message: message.isNotEmpty ? message : 'Resource not found.');
      case 422:
        return ValidationFailure(
            message: message.isNotEmpty ? message : 'Validation failed.');
      case 429:
        return ServerFailure(
            message: 'Too many requests. Please try again later.');
      case 500:
        return ServerFailure(
            message: 'Internal server error. Please try again later.');
      case 502:
        return ServerFailure(message: 'Bad gateway. Please try again later.');
      case 503:
        return ServerFailure(
            message: 'Service unavailable. Please try again later.');
      default:
        return ServerFailure(
            message: message.isNotEmpty ? message : 'Server error occurred.');
    }
  }

  /// Handle generic exceptions
  static Failure handleGenericError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    }

    // Log error in debug mode
    if (kDebugMode) {
      debugPrint('Generic error: $error');
    }

    return const ServerFailure(
        message: 'An unexpected error occurred. Please try again.');
  }

  /// Show error message to user
  static void showErrorSnackBar(BuildContext context, Failure failure) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failure.message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    Failure failure, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Error'),
          content: Text(failure.message),
          actions: <Widget>[
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Log error for debugging/analytics
  static void logError(dynamic error,
      {StackTrace? stackTrace, Map<String, dynamic>? additionalData}) {
    if (kDebugMode) {
      debugPrint('=== ERROR LOG ===');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack Trace: $stackTrace');
      }
      if (additionalData != null) {
        debugPrint('Additional Data: $additionalData');
      }
      debugPrint('================');
    }

    // In production, you would send this to your logging service
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
