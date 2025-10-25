import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/wallet_models.dart';
import '../data/repositories/wallet_repository.dart';

// Wallet State Provider
final walletProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<WalletResponse?>>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});

// Wallet Balance Provider
final walletBalanceProvider =
    StateNotifierProvider<WalletBalanceNotifier, AsyncValue<WalletBalance?>>(
        (ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletBalanceNotifier(repository);
});

// Transfer State Provider
final transferProvider =
    StateNotifierProvider<TransferNotifier, AsyncValue<TransferResponse?>>(
        (ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return TransferNotifier(repository);
});

class WalletNotifier extends StateNotifier<AsyncValue<WalletResponse?>> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Create a new wallet
  Future<void> createWallet() async {
    state = const AsyncValue.loading();
    try {
      final wallet = await _repository.createWallet();
      state = AsyncValue.data(wallet);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get the current user's wallet
  Future<void> getMyWallet() async {
    state = const AsyncValue.loading();
    try {
      final wallet = await _repository.getMyWallet();
      state = AsyncValue.data(wallet);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh wallet data
  Future<void> refresh() async {
    await getMyWallet();
  }

  /// Clear wallet state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

class WalletBalanceNotifier extends StateNotifier<AsyncValue<WalletBalance?>> {
  final WalletRepository _repository;

  WalletBalanceNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Get the current user's wallet balance
  Future<void> getBalance() async {
    state = const AsyncValue.loading();
    try {
      final balance = await _repository.getMyWalletBalance();
      state = AsyncValue.data(balance);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh balance
  Future<void> refresh() async {
    await getBalance();
  }

  /// Clear balance state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

class TransferNotifier extends StateNotifier<AsyncValue<TransferResponse?>> {
  final WalletRepository _repository;

  TransferNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Transfer HBAR to another account
  Future<void> transferHbar({
    required String toAccountId,
    required String amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.transferHbar(
        toAccountId: toAccountId,
        amount: amount,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear transfer state
  void clear() {
    state = const AsyncValue.data(null);
  }
}

// Convenience providers for easier access
final hasWalletProvider = Provider<bool>((ref) {
  final walletState = ref.watch(walletProvider);
  return walletState.when(
    data: (wallet) => wallet != null,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

final walletBalanceStringProvider = Provider<String>((ref) {
  final balanceState = ref.watch(walletBalanceProvider);
  return balanceState.when(
    data: (balance) => balance?.formattedHbarBalance ?? '0.00 HBAR',
    loading: () => 'Loading...',
    error: (error, stackTrace) => '0.00 HBAR',
  );
});

final canTransferProvider = Provider<bool>((ref) {
  final walletState = ref.watch(walletProvider);
  final balanceState = ref.watch(walletBalanceProvider);

  return walletState.when(
        data: (wallet) => wallet != null,
        loading: () => false,
        error: (error, stackTrace) => false,
      ) &&
      balanceState.when(
        data: (balance) => balance != null && balance.hbarBalance > 0,
        loading: () => false,
        error: (error, stackTrace) => false,
      );
});
