import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';

final adminTradesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllTrades(page: 1, limit: 100);
});

final adminTradesActionsProvider = Provider<AdminTradesActions>((ref) => AdminTradesActions(ref.watch(adminRepositoryProvider)));

class AdminTradesActions {
  final AdminRepository _repo;
  AdminTradesActions(this._repo);

  Future<void> cancel(String id) => _repo.cancelTrade(id);
}

