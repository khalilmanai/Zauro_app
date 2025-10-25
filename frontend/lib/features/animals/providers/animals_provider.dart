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
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
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
      state = AsyncValue.data(animals);
    } catch (error, stackTrace) {
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

  /// Refresh animal data
  Future<void> refresh() async {
    await getAnimal();
  }
}

class MyAnimalsNotifier extends StateNotifier<AsyncValue<List<Animal>>> {
  final AnimalsRepository _repository;

  MyAnimalsNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get user's animals
  Future<void> getMyAnimals() async {
    state = const AsyncValue.loading();
    try {
      final animals = await _repository.getMyAnimals();
      state = AsyncValue.data(animals);
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
    await getMyAnimals();
  }

  /// Clear my animals state
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
