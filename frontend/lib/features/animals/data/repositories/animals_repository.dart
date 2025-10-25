import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/animal_models.dart';

// Animals Repository Provider
final animalsRepositoryProvider = Provider<AnimalsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dio = ref.watch(dioProvider);
  return AnimalsRepository(apiClient, dio);
});

class AnimalsRepository {
  final ApiClient _apiClient;
  final Dio _dio;

  AnimalsRepository(this._apiClient, this._dio);

  /// Create a new animal with optional image upload
  Future<Animal> createAnimal({
    required CreateAnimalRequest request,
    File? imageFile,
    File? vetRecordFile,
  }) async {
    try {
      // If no files, use simple API call
      if (imageFile == null && vetRecordFile == null) {
        final response = await _apiClient.createAnimal(request);

        if (response.success && response.data != null) {
          return response.data!;
        } else {
          throw ServerFailure(message: response.message);
        }
      }

      // Use multipart form data for file uploads
      final formData = FormData.fromMap({
        'name': request.name,
        'species': request.species,
        'breed': request.breed,
        'age': request.age,
        'description': request.description,
        'aiPredictionValue': request.aiPredictionValue,
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'animal_image.jpg',
          ),
        if (vetRecordFile != null)
          'vetRecord': await MultipartFile.fromFile(
            vetRecordFile.path,
            filename: 'vet_record.pdf',
          ),
      });

      final response = await _dio.post(
        '/animals',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];
        return Animal.fromJson(data);
      } else {
        throw ServerFailure(message: 'Failed to create animal');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to create animal: $e');
    }
  }

  /// Get all animals with pagination and optional filtering
  Future<PaginatedResponse<Animal>> getAnimals({
    int page = 1,
    int limit = 10,
    String? ownerId,
  }) async {
    try {
      final response = await _apiClient.getAnimals(page, limit, ownerId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get animals: $e');
    }
  }

  /// Get animal by ID
  Future<Animal> getAnimal(String id) async {
    try {
      final response = await _apiClient.getAnimal(id);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get animal: $e');
    }
  }

  /// Update animal metadata
  Future<Animal> updateAnimal({
    required String id,
    required UpdateAnimalRequest request,
  }) async {
    try {
      final response = await _apiClient.updateAnimal(id, request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to update animal: $e');
    }
  }

  /// Delete animal
  Future<void> deleteAnimal(String id) async {
    try {
      final response = await _apiClient.deleteAnimal(id);

      if (!response.success) {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to delete animal: $e');
    }
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
          filename: 'animal_image.jpg',
        ),
      });

      final response = await _dio.post(
        '/animals/$animalId/upload-image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Animal.fromJson(data);
      } else {
        throw ServerFailure(message: 'Failed to upload image');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to upload image: $e');
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
          filename: 'vet_record.pdf',
        ),
      });

      final response = await _dio.post(
        '/animals/$animalId/upload-vet-record',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Animal.fromJson(data);
      } else {
        throw ServerFailure(message: 'Failed to upload vet record');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to upload vet record: $e');
    }
  }

  /// Get user's animals
  Future<List<Animal>> getMyAnimals() async {
    try {
      final response = await getAnimals(ownerId: 'me');
      return response.data;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get my animals: $e');
    }
  }

  /// Search animals by query
  Future<List<Animal>> searchAnimals(String query) async {
    try {
      final response = await getAnimals();
      return response.data.where((animal) {
        return animal.name.toLowerCase().contains(query.toLowerCase()) ||
            animal.species.toLowerCase().contains(query.toLowerCase()) ||
            (animal.breed?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to search animals: $e');
    }
  }
}
