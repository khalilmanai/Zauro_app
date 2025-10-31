import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/admin_repository.dart';

class AdminStats {
  final int? users;
  final int pendingAnimals;
  final int activeTrades;
  final int collections;
  const AdminStats({this.users, required this.pendingAnimals, required this.activeTrades, required this.collections});
}

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final results = await Future.wait([
    repo.getUsersCount(),
    repo.getPendingAnimalsCount(),
    repo.getActiveTradesCount(),
    repo.getCollectionsCount(),
  ]);
  final users = results[0] is int ? results[0] as int : null;
  final pending = results[1] as int;
  final trades = results[2] as int;
  final collections = results[3] as int;
  return AdminStats(users: users, pendingAnimals: pending, activeTrades: trades, collections: collections);
});

