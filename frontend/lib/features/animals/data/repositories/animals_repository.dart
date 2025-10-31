import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  /// Uses multipart/form-data as required by backend for file uploads
  Future<Animal> createAnimal({
    required CreateAnimalRequest request,
    File? imageFile,
    File? vetRecordFile,
  }) async {
    try {
      // Always use multipart form data to match backend endpoint specification
      // Backend expects: POST /api/v1/animals with multipart/form-data
      final formData = FormData.fromMap({
        'name': request.name,
        'species': request.species,
        'gender': request.gender,
        if (request.breed != null && request.breed!.isNotEmpty) 
          'breed': request.breed,
        if (request.age != null) 
          'age': request.age.toString(),
        if (request.description != null && request.description!.isNotEmpty) 
          'description': request.description,
        if (request.aiPredictionValue != null)
          'aiPredictionValue': request.aiPredictionValue.toString(),
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split(Platform.pathSeparator).last,
          ),
        if (vetRecordFile != null)
          'vetRecord': await MultipartFile.fromFile(
            vetRecordFile.path,
            filename: vetRecordFile.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await _dio.post(
        '/animals',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      // Handle response - backend returns 201 Created with wrapped response
      if (response.statusCode == 201) {
        // Handle wrapped response format: { success, message, data }
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          
          // Check if response has wrapped structure
          if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is Map<String, dynamic>) {
              return Animal.fromJson(data);
            } else {
              throw ServerFailure(
                message: responseMap['message'] as String? ?? 
                        'Invalid response format: data is not an object',
              );
            }
          } else {
            // Direct animal object (unwrapped)
            return Animal.fromJson(responseMap);
          }
        } else {
          throw ServerFailure(message: 'Invalid response format from server');
        }
      } else if (response.statusCode == 400) {
        // Bad request - validation error
        final errorMessage = response.data is Map
            ? (response.data as Map)['message'] ?? 
              (response.data as Map)['error'] ?? 
              'Validation failed. Please check your input.'
            : 'Validation failed. Please check your input.';
        throw ServerFailure(message: errorMessage.toString());
      } else if (response.statusCode == 401) {
        throw ServerFailure(message: 'Authentication required. Please log in again.');
      } else {
        final errorMessage = response.data is Map
            ? (response.data as Map)['message'] ?? 
              (response.data as Map)['error'] ?? 
              'Failed to create animal. Please try again.'
            : 'Failed to create animal. Please try again.';
        throw ServerFailure(
          message: '${errorMessage} (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        String errorMessage = 'Failed to create animal';
        if (responseData is Map) {
          errorMessage = responseData['message'] ?? 
                        responseData['error'] ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        if (statusCode == 400) {
          throw ServerFailure(message: errorMessage);
        } else if (statusCode == 401) {
          throw ServerFailure(message: 'Authentication required. Please log in again.');
        } else if (statusCode == 413) {
          throw ServerFailure(message: 'File size too large. Please use a smaller image.');
        } else {
          throw ServerFailure(message: '$errorMessage (Status: $statusCode)');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw ServerFailure(message: 'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerFailure(message: 'Network error. Please check your internet connection.');
      } else {
        throw ServerFailure(message: 'Failed to create animal: ${e.message}');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      debugPrint('❌ Unexpected error in createAnimal: $e');
      throw ServerFailure(
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Get all animals with pagination and optional filtering
  Future<PaginatedResponse<Animal>> getAnimals({
    int page = 1,
    int limit = 10,
    String? ownerId,
  }) async {
    try {
      // This endpoint returns { success, message, data: [..], pagination: {...} }
      final rawResp = await _apiClient.getAnimals(page, limit, ownerId);
      final raw = rawResp.data as Map<String, dynamic>;
      
      // Handle case where data might be directly a list (some endpoints)
      dynamic dataValue = raw['data'];
      if (dataValue == null) {
        return PaginatedResponse<Animal>(
          data: [],
          pagination: PaginationInfo(
            page: page,
            limit: limit,
            total: 0,
            totalPages: 0,
          ),
        );
      }
      
      final List<dynamic> list = dataValue is List ? dataValue : [];
      
      final animals = <Animal>[];
      for (final item in list) {
        try {
          if (item is Map<String, dynamic>) {
            animals.add(Animal.fromJson(item));
          }
        } catch (e) {
          // Log but don't fail on individual item parsing errors
          debugPrint('⚠️ Failed to parse animal: $e');
          debugPrint('   Animal data: $item');
        }
      }
      
      final pagination = PaginationInfo.fromJson(
        (raw['pagination'] as Map<String, dynamic>? ?? {}),
      );
      
      return PaginatedResponse<Animal>(data: animals, pagination: pagination);
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getAnimals: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get animals: ${e.toString()}');
    }
  }

  /// Get listed animals (marketplace) - uses /api/v1/animals/listed endpoint
  Future<PaginatedResponse<Animal>> getListedAnimals({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // This endpoint returns { success, message, data: [..], pagination: {...} }
      final rawResp = await _apiClient.getListedAnimals(page, limit);
      final raw = rawResp.data as Map<String, dynamic>;
      
      // Handle case where data might be directly a list (some endpoints)
      dynamic dataValue = raw['data'];
      if (dataValue == null) {
        return PaginatedResponse<Animal>(
          data: [],
          pagination: PaginationInfo(
            page: page,
            limit: limit,
            total: 0,
            totalPages: 0,
          ),
        );
      }
      
      final List<dynamic> list = dataValue is List ? dataValue : [];
      
      final animals = <Animal>[];
      for (final item in list) {
        try {
          if (item is Map<String, dynamic>) {
            animals.add(Animal.fromJson(item));
          }
        } catch (e) {
          // Log but don't fail on individual item parsing errors
          debugPrint('⚠️ Failed to parse listed animal: $e');
          debugPrint('   Animal data: $item');
        }
      }
      
      final pagination = PaginationInfo.fromJson(
        (raw['pagination'] as Map<String, dynamic>? ?? {}),
      );
      
      return PaginatedResponse<Animal>(data: animals, pagination: pagination);
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getListedAnimals: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get listed animals: ${e.toString()}');
    }
  }

  /// Get animals pending expert review (Admin/Manager only)
  Future<PaginatedResponse<Animal>> getPendingReviewAnimals({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.getPendingReviewAnimals(page, limit);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get pending review animals: $e');
    }
  }

  /// Review an animal (approve/reject) - Admin/Manager only
  Future<Animal> reviewAnimal({
    required String id,
    required bool approved,
    String? comment,
  }) async {
    try {
      final request = ReviewAnimalRequest(
        approved: approved,
        comment: comment,
      );

      final response = await _apiClient.reviewAnimal(id, request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to review animal: $e');
    }
  }

  /// Mint NFT for approved animal
  /// Endpoint: POST /api/v1/animals/{id}/mint
  /// Animal must be in EXPERT_APPROVED status before minting
  Future<Animal> mintAnimal(String id) async {
    try {
      final response = await _apiClient.mintAnimal(id);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Extract meaningful error message
        String errorMessage = response.message;
        if (errorMessage.isEmpty || errorMessage.toLowerCase().contains('failed')) {
          errorMessage = 'Failed to mint NFT. Ensure the animal is approved by an expert.';
        }
        throw ServerFailure(message: errorMessage);
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        String errorMessage = 'Failed to mint NFT';
        if (responseData is Map) {
          errorMessage = responseData['message'] ?? 
                        responseData['error'] ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
        
        if (statusCode == 400) {
          // Bad request - might be animal not approved or already minted
          throw ServerFailure(
            message: errorMessage.contains('approved') || 
                     errorMessage.contains('status')
              ? errorMessage
              : 'Animal must be approved by an expert before minting.',
          );
        } else if (statusCode == 401) {
          throw ServerFailure(message: 'Authentication required. Please log in again.');
        } else if (statusCode == 403) {
          throw ServerFailure(message: 'You do not have permission to mint this NFT.');
        } else if (statusCode == 404) {
          throw ServerFailure(message: 'Animal not found.');
        } else if (statusCode == 409) {
          // Conflict - likely already minted
          throw ServerFailure(
            message: errorMessage.contains('mint') || 
                     errorMessage.contains('already')
              ? errorMessage
              : 'This animal NFT has already been minted.',
          );
        } else {
          throw ServerFailure(message: '$errorMessage (Status: $statusCode)');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        throw ServerFailure(message: 'Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerFailure(message: 'Network error. Please check your internet connection.');
      } else {
        throw ServerFailure(message: 'Failed to mint NFT: ${e.message}');
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      debugPrint('❌ Unexpected error in mintAnimal: $e');
      throw ServerFailure(
        message: 'An unexpected error occurred while minting NFT. Please try again.',
      );
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
  Future<List<Animal>> getMyAnimals({int page = 1, int limit = 10}) async {
    try {
      debugPrint('📋 Fetching my animals (page=$page, limit=$limit)...');
      // Call dedicated endpoint /animals/my which returns
      // { success, message, data: [...], pagination: {...} }
      final rawResp = await _apiClient.getMyAnimals(page, limit);
      final raw = rawResp.data as Map<String, dynamic>;

      final List<dynamic> list = (raw['data'] as List?) ?? const [];
      final animals = <Animal>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            animals.add(Animal.fromJson(item));
          } catch (e) {
            debugPrint('⚠️ Failed to parse my animal: $e');
          }
        }
      }

      debugPrint('✅ Got ${animals.length} animals');
      return animals;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getMyAnimals: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get my animals: ${e.toString()}');
    }
  }

  /// Get user's animals with pagination metadata
  Future<PaginatedResponse<Animal>> getMyAnimalsPaginated({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final rawResp = await _apiClient.getMyAnimals(page, limit);
      final raw = rawResp.data as Map<String, dynamic>;

      final List<dynamic> list = (raw['data'] as List?) ?? const [];
      final animals = <Animal>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            animals.add(Animal.fromJson(item));
          } catch (e) {
            debugPrint('⚠️ Failed to parse my animal: $e');
          }
        }
      }

      final pagination = PaginationInfo.fromJson(
        (raw['pagination'] as Map<String, dynamic>? ?? {}),
      );

      return PaginatedResponse<Animal>(data: animals, pagination: pagination);
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get my animals (paginated): $e');
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
