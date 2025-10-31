import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/trade_models.dart';
import '../data/repositories/trading_repository.dart';

// Trading State Provider
final tradesProvider =
    StateNotifierProvider<TradesNotifier, AsyncValue<List<Trade>>>((ref) {
  final repository = ref.watch(tradingRepositoryProvider);
  return TradesNotifier(repository);
});

// Single Trade Provider
final tradeProvider =
    StateNotifierProvider.family<TradeNotifier, AsyncValue<Trade?>, String>(
        (ref, id) {
  final repository = ref.watch(tradingRepositoryProvider);
  return TradeNotifier(repository, id);
});

// My Trades Provider (as seller)
final myTradesProvider =
    StateNotifierProvider<MyTradesNotifier, AsyncValue<List<Trade>>>((ref) {
  final repository = ref.watch(tradingRepositoryProvider);
  return MyTradesNotifier(repository);
});

// My Purchases Provider (as buyer)
final myPurchasesProvider =
    StateNotifierProvider<MyPurchasesNotifier, AsyncValue<List<Trade>>>((ref) {
  final repository = ref.watch(tradingRepositoryProvider);
  return MyPurchasesNotifier(repository);
});

// Marketplace Provider (available trades)
final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, AsyncValue<List<Trade>>>((ref) {
  final repository = ref.watch(tradingRepositoryProvider);
  return MarketplaceNotifier(repository);
});

class TradesNotifier extends StateNotifier<AsyncValue<List<Trade>>> {
  final TradingRepository _repository;

  TradesNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get all trades with pagination
  Future<void> getTrades({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.getTrades(
        page: page,
        limit: limit,
        status: status,
      );
      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search trades
  Future<void> searchTrades(String query) async {
    if (query.isEmpty) {
      await getTrades();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final trades = await _repository.searchTrades(query);
      state = AsyncValue.data(trades);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh trades list
  Future<void> refresh() async {
    await getTrades();
  }

  /// Clear trades state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

class TradeNotifier extends StateNotifier<AsyncValue<Trade?>> {
  final TradingRepository _repository;
  final String _tradeId;

  TradeNotifier(this._repository, this._tradeId)
      : super(const AsyncValue.data(null)) {
    getTrade();
  }

  /// Get trade by ID
  Future<void> getTrade() async {
    state = const AsyncValue.loading();
    try {
      final trade = await _repository.getTrade(_tradeId);
      state = AsyncValue.data(trade);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Buy animal (initiate trade)
  Future<void> buyAnimal() async {
    state = const AsyncValue.loading();
    try {
      final trade = await _repository.buyAnimal(_tradeId);
      state = AsyncValue.data(trade);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Execute trade
  Future<void> executeTrade() async {
    state = const AsyncValue.loading();
    try {
      final trade = await _repository.executeTrade(_tradeId);
      state = AsyncValue.data(trade);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Cancel trade
  Future<void> cancelTrade() async {
    state = const AsyncValue.loading();
    try {
      final trade = await _repository.cancelTrade(_tradeId);
      state = AsyncValue.data(trade);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh trade data
  Future<void> refresh() async {
    await getTrade();
  }
}

class MyTradesNotifier extends StateNotifier<AsyncValue<List<Trade>>> {
  final TradingRepository _repository;

  MyTradesNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get user's trades (as seller)
  Future<void> getMyTrades() async {
    state = const AsyncValue.loading();
    try {
      final trades = await _repository.getMyTrades();
      state = AsyncValue.data(trades);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create new trade
  Future<void> createTrade(CreateTradeRequest request) async {
    state = const AsyncValue.loading();
    try {
      final trade = await _repository.createTrade(request);

      // Add to current list
      final currentTrades = state.value ?? [];
      state = AsyncValue.data([trade, ...currentTrades]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update trade in list
  void updateTradeInList(Trade updatedTrade) {
    final currentTrades = state.value ?? [];
    final updatedTrades = currentTrades.map((trade) {
      return trade.id == updatedTrade.id ? updatedTrade : trade;
    }).toList();
    state = AsyncValue.data(updatedTrades);
  }

  /// Remove trade from list (after cancellation)
  void removeTrade(String tradeId) {
    final currentTrades = state.value ?? [];
    final updatedTrades =
        currentTrades.where((trade) => trade.id != tradeId).toList();
    state = AsyncValue.data(updatedTrades);
  }

  /// Refresh my trades
  Future<void> refresh() async {
    await getMyTrades();
  }

  /// Clear my trades state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

class MyPurchasesNotifier extends StateNotifier<AsyncValue<List<Trade>>> {
  final TradingRepository _repository;

  MyPurchasesNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get user's purchases (as buyer)
  Future<void> getMyPurchases() async {
    state = const AsyncValue.loading();
    try {
      final purchases = await _repository.getMyPurchases();
      state = AsyncValue.data(purchases);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update purchase in list
  void updatePurchaseInList(Trade updatedTrade) {
    final currentPurchases = state.value ?? [];
    final updatedPurchases = currentPurchases.map((trade) {
      return trade.id == updatedTrade.id ? updatedTrade : trade;
    }).toList();
    state = AsyncValue.data(updatedPurchases);
  }

  /// Refresh my purchases
  Future<void> refresh() async {
    await getMyPurchases();
  }

  /// Clear my purchases state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

class MarketplaceNotifier extends StateNotifier<AsyncValue<List<Trade>>> {
  final TradingRepository _repository;

  MarketplaceNotifier(this._repository) : super(const AsyncValue.data([]));

  /// Get available trades (marketplace)
  Future<void> getAvailableTrades() async {
    state = const AsyncValue.loading();
    try {
      final trades = await _repository.getAvailableTrades();
      // ignore: avoid_print
      print('✅ marketplaceProvider.getAvailableTrades -> ${trades.length}');
      state = AsyncValue.data(trades);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ marketplaceProvider.getAvailableTrades error: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Search marketplace
  Future<void> searchMarketplace(String query, {String? species}) async {
    if (query.isEmpty) {
      await getAvailableTrades();
      return;
    }

    state = const AsyncValue.loading();
    try {
      final trades = await _repository.searchTrades(query, species: species);
      // Server already filters by status=LISTED,ACTIVE; keep extra safety filter
      final availableTrades = trades
          .where((trade) => trade.status == 'ACTIVE' || trade.status == 'LISTED' || trade.isActive)
          .toList();
      state = AsyncValue.data(availableTrades);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh marketplace
  Future<void> refresh() async {
    await getAvailableTrades();
  }

  /// Clear marketplace state
  void clear() {
    state = const AsyncValue.data([]);
  }
}

// Convenience providers for easier access
final hasActiveTradesProvider = Provider<bool>((ref) {
  final tradesState = ref.watch(myTradesProvider);
  return tradesState.when(
    data: (trades) => trades.any((trade) => trade.status == 'ACTIVE'),
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

final activeTradesCountProvider = Provider<int>((ref) {
  final tradesState = ref.watch(myTradesProvider);
  return tradesState.when(
    data: (trades) => trades.where((trade) => trade.status == 'ACTIVE').length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

final pendingTradesCountProvider = Provider<int>((ref) {
  final tradesState = ref.watch(myTradesProvider);
  return tradesState.when(
    data: (trades) => trades.where((trade) => trade.status == 'PENDING').length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

final marketplaceCountProvider = Provider<int>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.when(
    data: (trades) => trades.length,
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});
