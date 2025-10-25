import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/storage_service.dart';

// File Upload Service Provider
final fileUploadServiceProvider = Provider<FileUploadService>((ref) {
  return FileUploadService();
});

class FileUploadService {
  late final Dio _dio;

  FileUploadService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.fullApiUrl,
      connectTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 2),
    ));

    // Add auth interceptor
    _dio.interceptors.add(_AuthInterceptor());
  }

  /// Upload animal image
  Future<String> uploadAnimalImage({
    required String animalId,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      await _uploadFile('/animals/$animalId/upload-image', formData);

      // Return a placeholder URL - actual URL would come from server response
      return 'https://supabase-url/animals/$animalId/image.jpg';
    } catch (e) {
      throw Exception('Failed to upload animal image: $e');
    }
  }

  /// Upload vet record
  Future<String> uploadVetRecord({
    required String animalId,
    required File vetRecordFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'vetRecord': await MultipartFile.fromFile(
          vetRecordFile.path,
          filename: vetRecordFile.path.split('/').last,
        ),
      });

      await _uploadFile('/animals/$animalId/upload-vet-record', formData);

      // Return a placeholder URL - actual URL would come from server response
      return 'https://supabase-url/animals/$animalId/vet_record.pdf';
    } catch (e) {
      throw Exception('Failed to upload vet record: $e');
    }
  }

  /// Generic file upload method
  Future<void> _uploadFile(String endpoint, FormData formData) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }
}

// Auth Interceptor for file uploads
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
