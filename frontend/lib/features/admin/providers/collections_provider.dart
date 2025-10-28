import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/collection_models.dart';
import '../data/repositories/collections_repository.dart';

// Collections State
class CollectionsState {
  final List<Collection> collections;
  final Collection? defaultCollection;
  final CollectionStats? stats;
  final bool isLoading;
  final String? error;

  const CollectionsState({
    this.collections = const [],
    this.defaultCollection,
    this.stats,
    this.isLoading = false,
    this.error,
  });

  CollectionsState copyWith({
    List<Collection>? collections,
    Collection? defaultCollection,
    CollectionStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return CollectionsState(
      collections: collections ?? this.collections,
      defaultCollection: defaultCollection ?? this.defaultCollection,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Helper getters
  bool get hasCollections => collections.isNotEmpty;
  
  List<Collection> get activeCollections =>
      collections.where((c) => c.isActive).toList();
  
  List<Collection> get inactiveCollections =>
      collections.where((c) => !c.isActive).toList();
  
  List<Collection> get fullCollections =>
      collections.where((c) => c.isFull).toList();
  
  int get totalCollections => collections.length;
  int get activeCount => activeCollections.length;
  int get fullCount => fullCollections.length;
}

// Collections Notifier
class CollectionsNotifier extends StateNotifier<CollectionsState> {
  final CollectionsRepository _repository;

  CollectionsNotifier(this._repository) : super(const CollectionsState());

  // Load Collections
  Future<void> loadCollections() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final collections = await _repository.listCollections();
      final defaultCollection = collections
          .where((c) => c.isDefault)
          .firstOrNull;
      final stats = CollectionStats.fromCollections(collections);
      
      state = state.copyWith(
        collections: collections,
        defaultCollection: defaultCollection,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load collections: $e',
      );
    }
  }

  // Create Collection
  Future<bool> createCollection({
    required String name,
    required String symbol,
    String? memo,
    int? maxSupply,
    bool? isDefault,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final collection = await _repository.createCollection(
        name: name,
        symbol: symbol,
        memo: memo,
        maxSupply: maxSupply,
        isDefault: isDefault,
      );
      
      // Add the new collection to the list
      final updatedCollections = [...state.collections, collection];
      
      // Update default collection if this is the new default
      final newDefaultCollection =
          isDefault == true ? collection : state.defaultCollection;
      
      final stats = CollectionStats.fromCollections(updatedCollections);
      
      state = state.copyWith(
        collections: updatedCollections,
        defaultCollection: newDefaultCollection,
        stats: stats,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create collection: $e',
      );
      return false;
    }
  }

  // Get Default Collection
  Future<void> loadDefaultCollection() async {
    try {
      final collection = await _repository.getDefaultCollection();
      state = state.copyWith(defaultCollection: collection);
    } catch (e) {
      state = state.copyWith(error: 'Failed to get default collection: $e');
    }
  }

  // Rotate Collections If Full
  Future<bool> rotateCollectionsIfFull({
    String? namePrefix,
    String? symbolPrefix,
    String? memo,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final collection = await _repository.rotateCollectionsIfFull(
        namePrefix: namePrefix,
        symbolPrefix: symbolPrefix,
        memo: memo,
      );
      
      state = state.copyWith(
        defaultCollection: collection,
        isLoading: false,
      );
      
      // Reload collections to get updated list
      await loadCollections();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to rotate collections: $e',
      );
      return false;
    }
  }

  // Disable Collection
  Future<bool> disableCollection(String collectionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedCollection =
          await _repository.disableCollection(collectionId);
      
      // Update the collection in the list
      final updatedCollections = state.collections.map((c) {
        return c.id == collectionId ? updatedCollection : c;
      }).toList();
      
      final stats = CollectionStats.fromCollections(updatedCollections);
      
      state = state.copyWith(
        collections: updatedCollections,
        stats: stats,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to disable collection: $e',
      );
      return false;
    }
  }

  // Set Collection as Default
  Future<bool> setCollectionAsDefault(String collectionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedCollection =
          await _repository.setCollectionAsDefault(collectionId);
      
      // Update the collections list - only one can be default
      final updatedCollections = state.collections.map((c) {
        if (c.id == collectionId) {
          return updatedCollection;
        } else if (c.isDefault) {
          // Remove default from previous default collection
          return c.copyWith(isDefault: false);
        }
        return c;
      }).toList();
      
      final stats = CollectionStats.fromCollections(updatedCollections);
      
      state = state.copyWith(
        collections: updatedCollections,
        defaultCollection: updatedCollection,
        stats: stats,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to set collection as default: $e',
      );
      return false;
    }
  }

  // Search Collections
  Future<void> searchCollections(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final collections = await _repository.searchCollections(query);
      final stats = CollectionStats.fromCollections(collections);
      
      state = state.copyWith(
        collections: collections,
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search collections: $e',
      );
    }
  }

  // Filter Collections
  void filterCollections(CollectionFilter filter) {
    if (state.collections.isEmpty) return;
    
    final filtered = filter.apply(state.collections);
    final stats = CollectionStats.fromCollections(filtered);
    
    state = state.copyWith(
      collections: filtered,
      stats: stats,
    );
  }

  // Sort Collections
  void sortCollections(CollectionSortBy sortBy) {
    if (state.collections.isEmpty) return;
    
    final sorted = sortBy.apply(state.collections);
    
    state = state.copyWith(collections: sorted);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset state
  void reset() {
    state = const CollectionsState();
  }
}

// Provider
final collectionsProvider =
    StateNotifierProvider<CollectionsNotifier, CollectionsState>((ref) {
  final repository = ref.watch(collectionsRepositoryProvider);
  return CollectionsNotifier(repository);
});

// Helper providers

// Default collection provider
final defaultCollectionProvider = FutureProvider<Collection>((ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return await repository.getDefaultCollection();
});

// Check if default collection is full
final isDefaultCollectionFullProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return await repository.isDefaultCollectionFull();
});

// Get collection stats
final collectionStatsProvider =
    FutureProvider<CollectionStats>((ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return await repository.getCollectionStats();
});

// Get active collections
final activeCollectionsProvider =
    FutureProvider<List<Collection>>((ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return await repository.getActiveCollections();
});

// Get full collections
final fullCollectionsProvider = FutureProvider<List<Collection>>((ref) async {
  final repository = ref.watch(collectionsRepositoryProvider);
  return await repository.getFullCollections();
});

// Get collection by ID
final collectionByIdProvider = FutureProvider.family<Collection?, String>(
  (ref, collectionId) async {
    final repository = ref.watch(collectionsRepositoryProvider);
    return await repository.getCollectionById(collectionId);
  },
);


