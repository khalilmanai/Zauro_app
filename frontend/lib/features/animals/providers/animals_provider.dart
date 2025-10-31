import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../data/models/animal_models.dart';
import '../data/repositories/animals_repository.dart';

// Animals State Provider
final animalsProvider =
    StateNotifierProvider<AnimalsNotifier, AsyncValue<List<Animal>>>((ref) {
  final repository = ref.watch(animalsRepositoryProvider);
  return AnimalsNotifier(repository);
});

// Single Animal Provider
final animalProvider =
    StateNotifierProvider.family<AnimalNotifier, AsyncValue<Animal?>, String>(
        (ref, id) {
  final repository = ref.watch(animalsRepositoryProvider);
  return AnimalNotifier(repository, id);
});

// My Animals Provider
final myAnimalsProvider =
    StateNotifierProvider<MyAnimalsNotifier, AsyncValue<List<Animal>>>((ref) {
  final repository = ref.watch(animalsRepositoryProvider);
  return MyAnimalsNotifier(repository);
});

// Pending Review Animals Provider (Admin/Manager only)
final pendingReviewAnimalsProvider = StateNotifierProvider<
    PendingReviewAnimalsNotifier, AsyncValue<List<Animal>>>((ref) {
  final repository = ref.watch(animalsRepositoryProvider);
  return PendingReviewAnimalsNotifier(repository);
});

class AnimalsNotifier extends StateNotifier<AsyncValue<List<Animal>>> {
  final AnimalsRepository _repository;

  AnimalsNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get all animals with pagination
  Future<void> getAnimals({
    int page = 1,
    int limit = 10,
    String? ownerId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getAnimals(
        page: page,
        limit: limit,
        ownerId: ownerId,
      );
      // Log success and item count for debugging
      // ignore: avoid_print
      print('✅ animalsProvider.getAnimals -> ${response.data.length} items');
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ animalsProvider.getAnimals error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search animals
  Future<void> searchAnimals(String query) async {
    if (query.isEmpty) {
      await getAnimals();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final animals = await _repository.searchAnimals(query);
      // ignore: avoid_print
      print('🔎 animalsProvider.searchAnimals("$query") -> ${animals.length}');
      state = AsyncValue.data(animals);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ animalsProvider.searchAnimals error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh animals list
  Future<void> refresh() async {
    await getAnimals();
  }

  /// Clear animals state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

class AnimalNotifier extends StateNotifier<AsyncValue<Animal?>> {
  final AnimalsRepository _repository;
  final String _animalId;

  AnimalNotifier(this._repository, this._animalId)
      : super(const AsyncValue.data(null)) {
    getAnimal();
  }

  /// Get animal by ID
  Future<void> getAnimal() async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.getAnimal(_animalId);
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update animal
  Future<void> updateAnimal(UpdateAnimalRequest request) async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.updateAnimal(
        id: _animalId,
        request: request,
      );
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete animal
  Future<void> deleteAnimal() async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteAnimal(_animalId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Upload animal image
  Future<void> uploadImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.uploadAnimalImage(
        animalId: _animalId,
        imageFile: imageFile,
      );
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Upload vet record
  Future<void> uploadVetRecord(File vetRecordFile) async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.uploadVetRecord(
        animalId: _animalId,
        vetRecordFile: vetRecordFile,
      );
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Review animal (Admin/Manager only)
  Future<void> reviewAnimal({
    required bool approved,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.reviewAnimal(
        id: _animalId,
        approved: approved,
        comment: comment,
      );
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mint NFT for approved animal
  Future<void> mintAnimal() async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.mintAnimal(_animalId);
      state = AsyncValue.data(animal);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh animal data
  Future<void> refresh() async {
    await getAnimal();
  }
}

class MyAnimalsNotifier extends StateNotifier<AsyncValue<List<Animal>>> {
  final AnimalsRepository _repository;
  int _currentPage = 1;
  int _totalPages = 1;
  int _limit = 10;

  MyAnimalsNotifier(this._repository) : super(const AsyncValue.data([]));

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get limit => _limit;

  /// Get user's animals
  Future<void> getMyAnimals({int page = 1, int limit = 10}) async {
    state = const AsyncValue.loading();
    try {
      final resp = await _repository.getMyAnimalsPaginated(page: page, limit: limit);
      _currentPage = resp.pagination.page;
      _totalPages = resp.pagination.totalPages;
      _limit = resp.pagination.limit;
      state = AsyncValue.data(resp.data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Jump to a specific page
  Future<void> goToPage(int page) async {
    final target = page.clamp(1, _totalPages == 0 ? 1 : _totalPages);
    await getMyAnimals(page: target, limit: _limit);
  }

  /// Update page size and reset to first page
  Future<void> setLimit(int newLimit) async {
    _limit = newLimit;
    await getMyAnimals(page: 1, limit: _limit);
  }

  /// Load next page and append to the current list if available
  Future<void> loadMore() async {
    // Avoid calling if already loading or no more pages
    if (state.isLoading) return;
    if (_currentPage >= (_totalPages == 0 ? 1 : _totalPages)) return;

    final current = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final resp = await _repository.getMyAnimalsPaginated(
        page: _currentPage + 1,
        limit: _limit,
      );
      _currentPage = resp.pagination.page;
      _totalPages = resp.pagination.totalPages;
      _limit = resp.pagination.limit;
      state = AsyncValue.data([...current, ...resp.data]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create new animal
  Future<void> createAnimal({
    required CreateAnimalRequest request,
    File? imageFile,
    File? vetRecordFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final animal = await _repository.createAnimal(
        request: request,
        imageFile: imageFile,
        vetRecordFile: vetRecordFile,
      );

      // Add to current list
      final currentAnimals = state.value ?? [];
      state = AsyncValue.data([animal, ...currentAnimals]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Remove animal from list (after deletion)
  void removeAnimal(String animalId) {
    final currentAnimals = state.value ?? [];
    final updatedAnimals =
        currentAnimals.where((animal) => animal.id != animalId).toList();
    state = AsyncValue.data(updatedAnimals);
  }

  /// Update animal in list
  void updateAnimalInList(Animal updatedAnimal) {
    final currentAnimals = state.value ?? [];
    final updatedAnimals = currentAnimals.map((animal) {
      return animal.id == updatedAnimal.id ? updatedAnimal : animal;
    }).toList();
    state = AsyncValue.data(updatedAnimals);
  }

  /// Refresh my animals
  Future<void> refresh() async {
    await getMyAnimals(page: _currentPage, limit: _limit);
  }

  /// Clear my animals state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

class PendingReviewAnimalsNotifier
    extends StateNotifier<AsyncValue<List<Animal>>> {
  final AnimalsRepository _repository;

  PendingReviewAnimalsNotifier(this._repository)
      : super(const AsyncValue.data([]));

  /// Get animals pending expert review
  Future<void> getPendingReviewAnimals({
    int page = 1,
    int limit = 10,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getPendingReviewAnimals(
        page: page,
        limit: limit,
      );
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Review and approve an animal
  Future<void> approveAnimal(String animalId, {String? comment}) async {
    try {
      await _repository.reviewAnimal(
        id: animalId,
        approved: true,
        comment: comment,
      );

      // Remove from pending list
      final currentAnimals = state.value ?? [];
      final updatedAnimals =
          currentAnimals.where((a) => a.id != animalId).toList();
      state = AsyncValue.data(updatedAnimals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Review and reject an animal
  Future<void> rejectAnimal(String animalId, {String? comment}) async {
    try {
      await _repository.reviewAnimal(
        id: animalId,
        approved: false,
        comment: comment,
      );

      // Remove from pending list
      final currentAnimals = state.value ?? [];
      final updatedAnimals =
          currentAnimals.where((a) => a.id != animalId).toList();
      state = AsyncValue.data(updatedAnimals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh pending animals
  Future<void> refresh() async {
    await getPendingReviewAnimals();
  }

  /// Clear pending animals state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

// Convenience providers for easier access
final hasAnimalsProvider = Provider<bool>((ref) {
  final animalsState = ref.watch(myAnimalsProvider);
  return animalsState.when(
    data: (animals) => animals.isNotEmpty,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

final animalsCountProvider = Provider<int>((ref) {
  final animalsState = ref.watch(myAnimalsProvider);
  return animalsState.when(
    data: (animals) => animals.length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

final availableAnimalsProvider = Provider<List<Animal>>((ref) {
  final animalsState = ref.watch(animalsProvider);
  return animalsState.when(
    data: (animals) => animals.where((animal) => animal.isListed).toList(),
    loading: () => [],
    error: (error, stackTrace) => [],
  );
});
