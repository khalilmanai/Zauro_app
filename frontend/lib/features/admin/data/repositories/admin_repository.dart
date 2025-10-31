import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zauro_marketplace/features/animals/data/models/animal_models.dart';
import '../../../../core/network/api_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AdminRepository(api);
});

class AdminRepository {
  final ApiClient _api;
  AdminRepository(this._api);

  Future<int> getPendingAnimalsCount() async {
    try {
      // Prefer pagination total for accuracy
      final res = await _api.dio.get('/animals/pending-review', queryParameters: {
        'page': 1,
        'limit': 1,
      });
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final pagination = data['pagination'];
        if (pagination is Map<String, dynamic> && pagination['total'] is int) {
          return pagination['total'] as int;
        }
        final inner = data['data'];
        if (inner is List) return inner.length;
      }
      if (data is List) return data.length;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getActiveTradesCount() async {
    try {
      // Ask backend for listed and active trades; prefer pagination total
      final res = await _api.dio.get('/trades', queryParameters: {
        'page': 1,
        'limit': 1,
        'status': 'LISTED,ACTIVE',
      });
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final pagination = data['pagination'];
        if (pagination is Map<String, dynamic> && pagination['total'] is int) {
          return pagination['total'] as int;
        }
        final inner = data['data'];
        if (inner is List) return inner.length;
      }
      if (data is List) return data.length;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> getCollectionsCount() async {
    try {
      final res = await _api.listCollections();
      return res.data?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int?> getUsersCount() async {
    try {
      final res = await _api.dio.get('/auth/users');
      final data = res.data;
      if (data is List) return data.length;
      if (data is Map<String, dynamic>) {
        if (data['data'] is List) return (data['data'] as List).length;
        if (data['count'] is int) return data['count'] as int;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Animals moderation ---
  Future<List<Map<String, dynamic>>> getPendingAnimals(
      {int page = 1, int limit = 20}) async {
    // Use raw Dio to align with how the UI expects a list of maps
    final res = await _api.dio.get('/animals/pending-review', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final data = res.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) return inner.cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> reviewAnimal(String id,
      {required bool approved, String? comment}) async {
    await _api.reviewAnimal(
        id, ReviewAnimalRequest(approved: approved, comment: comment));
  }

  Future<void> deleteAnimal(String id) async {
    await _api.deleteAnimal(id);
  }

  // --- Trades moderation ---
  Future<List<Map<String, dynamic>>> getAllTrades(
      {int page = 1, int limit = 50}) async {
    final res = await _api.dio.get('/trades', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final data = res.data;
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> cancelTrade(String id) async {
    await _api.cancelTrade(id);
  }
}
