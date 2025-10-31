import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/trade_models.dart';

// Trading Repository Provider
final tradingRepositoryProvider = Provider<TradingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TradingRepository(apiClient);
});

class TradingRepository {
  final ApiClient _apiClient;

  TradingRepository(this._apiClient);

  /// Create a new trade (list animal for sale)
  Future<Trade> createTrade(CreateTradeRequest request) async {
    try {
      final response = await _apiClient.createTrade(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to create trade: $e');
    }
  }

  /// Get all trades with pagination and optional status filtering
  Future<PaginatedResponse<Trade>> getTrades({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final response = await _apiClient.getTrades(page, limit, status);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      // Fallback: some backends return a raw list instead of a paginated map
      try {
        final res = await _apiClient.dio.get('/trades', queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        });

        final data = res.data;
        List<dynamic> rawList;

        if (data is List) {
          rawList = data;
        } else if (data is Map<String, dynamic>) {
          // Try typical wrappers: { data: [...] } or ApiResponse { data: [...] }
          final inner = data['data'];
          if (inner is List) {
            rawList = inner;
          } else {
            throw ServerFailure(message: 'Unexpected trades response shape.');
          }
        } else {
          throw ServerFailure(message: 'Unknown trades response type.');
        }

        final trades = rawList
            .whereType<Map<String, dynamic>>()
            .map((j) => Trade.fromJson(j))
            .toList();

        return PaginatedResponse<Trade>(
          data: trades,
          pagination: PaginationInfo(page: page, limit: limit, total: trades.length, totalPages: 1),
        );
      } catch (fallbackError) {
        if (e is ServerFailure) rethrow;
        throw ServerFailure(message: 'Failed to get trades: $fallbackError');
      }
    }
  }

  /// Get trade by ID
  Future<Trade> getTrade(String id) async {
    try {
      final response = await _apiClient.getTrade(id);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get trade: $e');
    }
  }

  /// Buy an animal (initiate trade)
  Future<Trade> buyAnimal(String tradeId) async {
    try {
      final response = await _apiClient.buyAnimal(tradeId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to buy animal: $e');
    }
  }

  /// Execute trade (complete atomic swap)
  Future<Trade> executeTrade(String tradeId) async {
    try {
      final response = await _apiClient.executeTrade(tradeId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to execute trade: $e');
    }
  }

  /// Cancel a trade
  Future<Trade> cancelTrade(String tradeId) async {
    try {
      final response = await _apiClient.cancelTrade(tradeId);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to cancel trade: $e');
    }
  }

  /// Get available trades (marketplace)
  Future<List<Trade>> getAvailableTrades() async {
    try {
      // Prefer server-side filtering (status=LISTED,ACTIVE)
      final res = await _apiClient.dio.get('/trades', queryParameters: {
        // Some backends accept comma-separated values, others arrays. Send both safely.
        'status': 'LISTED,ACTIVE',
      });

      final data = res.data;
      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner == null) {
          return [];
        } else if (inner is List) {
          rawList = inner;
        } else {
          throw ServerFailure(message: 'Unexpected trades response shape.');
        }
      } else {
        throw ServerFailure(message: 'Unknown trades response type.');
      }

      final trades = rawList
          .whereType<Map<String, dynamic>>()
          .map((j) => _safeTradeFromJson(j))
          .whereType<Trade>()
          .toList();

      // Extra safety filter client-side
      return trades
          .where((t) => t.status == 'LISTED' || t.status == 'ACTIVE' || t.isActive)
          .toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get available trades: $e');
    }
  }

  Trade? _safeTradeFromJson(Map<String, dynamic> json) {
    try {
      // Normalize fields that must be strings
      void ensureString(String key) {
        final v = json[key];
        if (v != null && v is! String) {
          json[key] = v.toString();
        }
      }
      ensureString('id');
      ensureString('animalId');
      ensureString('sellerId');
      if (json.containsKey('buyerId')) ensureString('buyerId');
      ensureString('currency');
      ensureString('status');
      ensureString('createdAt');
      ensureString('updatedAt');
      if (json.containsKey('completedAt') && json['completedAt'] != null) {
        ensureString('completedAt');
      }

      // Normalize nested objects if present
      if (json['animal'] is Map<String, dynamic>) {
        final a = json['animal'] as Map<String, dynamic>;
        void ensureAnimalString(String k) {
          final v = a[k];
          if (v != null && v is! String) a[k] = v.toString();
        }
        ensureAnimalString('id');
        ensureAnimalString('name');
        ensureAnimalString('species');
        if (a.containsKey('breed')) ensureAnimalString('breed');
        ensureAnimalString('gender');
        if (a.containsKey('imageUrl')) ensureAnimalString('imageUrl');
        if (a.containsKey('tokenId')) ensureAnimalString('tokenId');
      }

      if (json['seller'] is Map<String, dynamic>) {
        final s = json['seller'] as Map<String, dynamic>;
        for (final k in ['id', 'firstName', 'lastName', 'email']) {
          final v = s[k];
          if (v != null && v is! String) s[k] = v.toString();
        }
      }

      if (json['buyer'] is Map<String, dynamic>) {
        final b = json['buyer'] as Map<String, dynamic>;
        for (final k in ['id', 'firstName', 'lastName', 'email']) {
          final v = b[k];
          if (v != null && v is! String) b[k] = v.toString();
        }
      }

      return Trade.fromJson(json);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Trade parse failed: $e');
      return null;
    }
  }

  /// Get user's trades (as seller)
  Future<List<Trade>> getMyTrades() async {
    try {
      final response = await getTrades();
      // Filter trades where current user is the seller
      return response.data.where((trade) => trade.sellerId.isNotEmpty).toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get my trades: $e');
    }
  }

  /// Get user's purchases (as buyer)
  Future<List<Trade>> getMyPurchases() async {
    try {
      final response = await getTrades();
      // Filter trades where current user is the buyer
      return response.data
          .where((trade) => trade.buyerId?.isNotEmpty == true)
          .toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get my purchases: $e');
    }
  }

  /// Get trade history
  Future<List<Trade>> getTradeHistory() async {
    try {
      final response = await getTrades();
      // Filter completed trades
      return response.data
          .where((trade) => trade.status == 'COMPLETED')
          .toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get trade history: $e');
    }
  }

  /// Search trades server-side with optional species filter
  /// Maps to: GET /api/v1/trades?search=query&species=COW&status=LISTED,ACTIVE
  Future<List<Trade>> searchTrades(String query, {String? species}) async {
    try {
      final res = await _apiClient.dio.get('/trades', queryParameters: {
        if (query.trim().isNotEmpty) 'search': query.trim(),
        if (species != null && species.isNotEmpty) 'species': species,
        'status': 'LISTED,ACTIVE',
      });

      final data = res.data;
      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is List) {
          rawList = inner;
        } else {
          throw ServerFailure(message: 'Unexpected trades response shape.');
        }
      } else {
        throw ServerFailure(message: 'Unknown trades response type.');
      }

      return rawList
          .whereType<Map<String, dynamic>>()
          .map((j) => Trade.fromJson(j))
          .toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to search trades: $e');
    }
  }

  /// Get trades by animal ID
  Future<List<Trade>> getTradesByAnimal(String animalId) async {
    try {
      final response = await getTrades();
      return response.data
          .where((trade) => trade.animalId == animalId)
          .toList();
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get trades by animal: $e');
    }
  }

  /// Get pending trades (awaiting execution)
  Future<List<Trade>> getPendingTrades() async {
    try {
      final response = await getTrades(status: 'PENDING');
      return response.data;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get pending trades: $e');
    }
  }
}
