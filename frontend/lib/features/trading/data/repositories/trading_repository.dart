import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get trades: $e');
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
      final response = await getTrades(status: 'ACTIVE');
      return response.data;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get available trades: $e');
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

  /// Search trades by animal name or description
  Future<List<Trade>> searchTrades(String query) async {
    try {
      final response = await getTrades();
      return response.data.where((trade) {
        return trade.animal?.name.toLowerCase().contains(query.toLowerCase()) ==
            true;
      }).toList();
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
