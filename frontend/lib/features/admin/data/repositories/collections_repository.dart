import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/collection_models.dart';

// Collections Repository Provider
final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CollectionsRepository(apiClient);
});

class CollectionsRepository {
  final ApiClient _apiClient;

  CollectionsRepository(this._apiClient);

  // Create Collection
  Future<Collection> createCollection({
    required String name,
    required String symbol,
    String? memo,
    int? maxSupply,
    bool? isDefault,
  }) async {
    try {
      final request = CreateCollectionRequest(
        name: name,
        symbol: symbol,
        memo: memo,
        maxSupply: maxSupply,
        isDefault: isDefault,
      );
      final response = await _apiClient.createCollection(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to create collection: ${response.message}');
    } catch (e) {
      throw Exception('Failed to create collection: $e');
    }
  }

  // List All Collections
  Future<List<Collection>> listCollections() async {
    try {
      final response = await _apiClient.listCollections();
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to list collections: ${response.message}');
    } catch (e) {
      throw Exception('Failed to list collections: $e');
    }
  }

  // Get Default Collection
  Future<Collection> getDefaultCollection() async {
    try {
      final response = await _apiClient.getDefaultCollection();
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to get default collection: ${response.message}');
    } catch (e) {
      throw Exception('Failed to get default collection: $e');
    }
  }

  // Rotate Collections If Full
  Future<Collection> rotateCollectionsIfFull({
    String? namePrefix,
    String? symbolPrefix,
    String? memo,
  }) async {
    try {
      final request = RotateCollectionRequest(
        namePrefix: namePrefix,
        symbolPrefix: symbolPrefix,
        memo: memo,
      );
      final response = await _apiClient.rotateCollectionsIfFull(request);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to rotate collections: ${response.message}');
    } catch (e) {
      throw Exception('Failed to rotate collections: $e');
    }
  }

  // Disable Collection
  Future<Collection> disableCollection(String collectionId) async {
    try {
      final response = await _apiClient.disableCollection(collectionId);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception('Failed to disable collection: ${response.message}');
    } catch (e) {
      throw Exception('Failed to disable collection: $e');
    }
  }

  // Set Collection as Default
  Future<Collection> setCollectionAsDefault(String collectionId) async {
    try {
      final response = await _apiClient.setCollectionAsDefault(collectionId);
      if (response.data != null) {
        return response.data!;
      }
      throw Exception(
          'Failed to set collection as default: ${response.message}');
    } catch (e) {
      throw Exception('Failed to set collection as default: $e');
    }
  }

  // Helper Methods

  // Get Active Collections
  Future<List<Collection>> getActiveCollections() async {
    try {
      final collections = await listCollections();
      return collections.where((c) => c.isActive).toList();
    } catch (e) {
      throw Exception('Failed to get active collections: $e');
    }
  }

  // Get Full Collections
  Future<List<Collection>> getFullCollections() async {
    try {
      final collections = await listCollections();
      return collections.where((c) => c.isFull).toList();
    } catch (e) {
      throw Exception('Failed to get full collections: $e');
    }
  }

  // Get Collection Stats
  Future<CollectionStats> getCollectionStats() async {
    try {
      final collections = await listCollections();
      return CollectionStats.fromCollections(collections);
    } catch (e) {
      throw Exception('Failed to get collection stats: $e');
    }
  }

  // Search Collections
  Future<List<Collection>> searchCollections(String query) async {
    try {
      final collections = await listCollections();
      final lowerQuery = query.toLowerCase();
      return collections
          .where((c) =>
              c.name.toLowerCase().contains(lowerQuery) ||
              c.symbol.toLowerCase().contains(lowerQuery) ||
              c.tokenId.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search collections: $e');
    }
  }

  // Get Collection by ID
  Future<Collection?> getCollectionById(String collectionId) async {
    try {
      final collections = await listCollections();
      return collections
          .where((c) => c.id == collectionId)
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Get Collection by Token ID
  Future<Collection?> getCollectionByTokenId(String tokenId) async {
    try {
      final collections = await listCollections();
      return collections
          .where((c) => c.tokenId == tokenId)
          .firstOrNull;
    } catch (e) {
      return null;
    }
  }

  // Check if default collection is full
  Future<bool> isDefaultCollectionFull() async {
    try {
      final defaultCollection = await getDefaultCollection();
      return defaultCollection.isFull;
    } catch (e) {
      return false;
    }
  }

  // Get available capacity for default collection
  Future<int> getDefaultCollectionCapacity() async {
    try {
      final defaultCollection = await getDefaultCollection();
      return defaultCollection.remainingCapacity;
    } catch (e) {
      return -1;
    }
  }

  // Filter Collections
  Future<List<Collection>> filterCollections(
      CollectionFilter filter) async {
    try {
      final collections = await listCollections();
      return filter.apply(collections);
    } catch (e) {
      throw Exception('Failed to filter collections: $e');
    }
  }

  // Sort Collections
  Future<List<Collection>> sortCollections(
      CollectionSortBy sortBy) async {
    try {
      final collections = await listCollections();
      return sortBy.apply(collections);
    } catch (e) {
      throw Exception('Failed to sort collections: $e');
    }
  }

  // Get Collections with Pagination
  Future<List<Collection>> getCollectionsPage({
    required int page,
    required int limit,
    CollectionFilter? filter,
    CollectionSortBy? sortBy,
  }) async {
    try {
      var collections = await listCollections();

      // Apply filter
      if (filter != null) {
        collections = filter.apply(collections);
      }

      // Apply sort
      if (sortBy != null) {
        collections = sortBy.apply(collections);
      }

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= collections.length) {
        return [];
      }

      return collections.sublist(
        startIndex,
        endIndex > collections.length ? collections.length : endIndex,
      );
    } catch (e) {
      throw Exception('Failed to get collections page: $e');
    }
  }

  // Get Total Collections Count
  Future<int> getTotalCollectionsCount({CollectionFilter? filter}) async {
    try {
      var collections = await listCollections();
      if (filter != null) {
        collections = filter.apply(collections);
      }
      return collections.length;
    } catch (e) {
      return 0;
    }
  }
}


