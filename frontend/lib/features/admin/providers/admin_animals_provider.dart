import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';

final adminPendingAnimalsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingAnimals(page: 1, limit: 50);
});

final adminAnimalsActionsProvider = Provider<AdminAnimalsActions>((ref) => AdminAnimalsActions(ref.watch(adminRepositoryProvider)));

class AdminAnimalsActions {
  final AdminRepository _repo;
  AdminAnimalsActions(this._repo);

  Future<void> approve(String id) => _repo.reviewAnimal(id, approved: true);
  Future<void> reject(String id) => _repo.reviewAnimal(id, approved: false);
  Future<void> remove(String id) => _repo.deleteAnimal(id);
}

