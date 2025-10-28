import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../utils/storage_service.dart';
import '../../features/animals/data/models/animal_models.dart';

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
  Future<Animal> uploadAnimalImage({
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

      final response =
          await _uploadFile('/animals/$animalId/upload-image', formData);
      
      // Parse the response to get the updated animal
      final data = response['data'] ?? response;
      return Animal.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upload animal image: $e');
    }
  }

  /// Upload vet record
  Future<Animal> uploadVetRecord({
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

      final response =
          await _uploadFile('/animals/$animalId/upload-vet-record', formData);
      
      // Parse the response to get the updated animal
      final data = response['data'] ?? response;
      return Animal.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to upload vet record: $e');
    }
  }

  /// Create animal with image
  Future<Animal> createAnimalWithImage({
    required String name,
    required String species,
    String? breed,
    int? age,
    required String gender,
    String? description,
    double? aiPredictionValue,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'species': species,
        if (breed != null) 'breed': breed,
        if (age != null) 'age': age,
        'gender': gender,
        if (description != null) 'description': description,
        if (aiPredictionValue != null) 'aiPredictionValue': aiPredictionValue,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _uploadFile('/animals', formData);
      
      // Parse the response to get the created animal
      final data = response['data'] ?? response;
      return Animal.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create animal with image: $e');
    }
  }

  /// Generic file upload method
  Future<Map<String, dynamic>> _uploadFile(
      String endpoint, FormData formData) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
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
