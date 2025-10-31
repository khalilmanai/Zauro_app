import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/wallet_models.dart';

// Wallet Repository Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient);
});

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository(this._apiClient);

  /// Create a new wallet for the authenticated user
  Future<Wallet> createWallet() async {
    try {
      final request =
          const CreateWalletRequest(); // Empty request, uses auth user
      final response = await _apiClient.createWallet(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to create wallet: $e');
    }
  }

  /// Get the authenticated user's wallet
  Future<Wallet> getMyWallet() async {
    try {
      print('🔍 Repository: Calling getMyWallet API');
      final wallet = await _apiClient.getMyWallet();
      print('🔍 Repository: Received wallet ${wallet.id}');
      return wallet;
    } catch (e) {
      print('❌ Repository: Exception in getMyWallet: $e');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get wallet: $e');
    }
  }

  /// Get the authenticated user's wallet balance
  Future<WalletBalance> getMyWalletBalance() async {
    try {
      // The balance endpoint returns WalletBalance directly (unwrapped)
      final balance = await _apiClient.getMyWalletBalanceRaw();

      print('🔍 Balance received: HBAR=${balance.hbar}, ZAU=${balance.zau}');
      print(
          '🔍 Parsed balance: HBAR=${balance.displayHbar}, ZAU=${balance.displayZau}');

      return balance;
    } catch (e) {
      print('❌ Repository exception: $e (${e.runtimeType})');
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get wallet balance: $e');
    }
  }

  /// Transfer HBAR to another Hedera account
  Future<TransferResponse> transferHbar({
    required String toAccountId,
    required String amount,
  }) async {
    try {
      // Validate Hedera account ID format
      if (!_isValidHederaAccountId(toAccountId)) {
        throw ValidationFailure(message: 'Invalid Hedera account ID format');
      }

      // Validate amount
      final amountDouble = double.tryParse(amount);
      if (amountDouble == null || amountDouble <= 0) {
        throw ValidationFailure(message: 'Invalid amount');
      }

      final request = TransferHbarRequest(
        toAccountId: toAccountId,
        amount: amount,
      );

      final response = await _apiClient.transferHbar(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure || e is ValidationFailure) rethrow;
      throw ServerFailure(message: 'Failed to transfer HBAR: $e');
    }
  }

  /// Get wallet by ID (for admin/authorized users)
  Future<Wallet> getWallet(String id) async {
    try {
      final response = await _apiClient.getWallet(id);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get wallet: $e');
    }
  }

  /// Get wallet balance by ID (for admin/authorized users)
  Future<WalletBalance> getWalletBalance(String id) async {
    try {
      // The balance endpoint returns WalletBalance directly (unwrapped)
      final balance = await _apiClient.getWalletBalanceRaw(id);
      return balance;
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure(message: 'Failed to get wallet balance: $e');
    }
  }

  /// Fund the authenticated user's wallet with HBAR
  Future<TransferResponse> fundMyAccount({
    required String amount,
    String? memo,
  }) async {
    try {
      // Validate amount
      final amountDouble = double.tryParse(amount);
      if (amountDouble == null || amountDouble <= 0) {
        throw ValidationFailure(message: 'Invalid amount');
      }

      final request = FundAccountRequest(
        amount: amount,
        memo: memo,
      );

      final response = await _apiClient.fundMyAccount(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure || e is ValidationFailure) rethrow;
      throw ServerFailure(message: 'Failed to fund account: $e');
    }
  }

  /// Fund any Hedera account with HBAR
  Future<TransferResponse> fundAccount({
    required String accountId,
    required String amount,
    String? memo,
  }) async {
    try {
      // Validate Hedera account ID format
      if (!_isValidHederaAccountId(accountId)) {
        throw ValidationFailure(message: 'Invalid Hedera account ID format');
      }

      // Validate amount
      final amountDouble = double.tryParse(amount);
      if (amountDouble == null || amountDouble <= 0) {
        throw ValidationFailure(message: 'Invalid amount');
      }

      final request = FundAccountRequest(
        accountId: accountId,
        amount: amount,
        memo: memo,
      );

      final response = await _apiClient.fundAccount(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure || e is ValidationFailure) rethrow;
      throw ServerFailure(message: 'Failed to fund account: $e');
    }
  }

  /// Create a new wallet with custom initial HBAR balance
  Future<Wallet> createWalletWithBalance({
    required String amount,
  }) async {
    try {
      // Validate amount
      final amountDouble = double.tryParse(amount);
      if (amountDouble == null || amountDouble <= 0) {
        throw ValidationFailure(message: 'Invalid amount');
      }

      final request = FundAccountRequest(
        amount: amount,
      );

      final response = await _apiClient.createWalletWithBalance(request);

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw ServerFailure(message: response.message);
      }
    } catch (e) {
      if (e is ServerFailure || e is ValidationFailure) rethrow;
      throw ServerFailure(message: 'Failed to create wallet with balance: $e');
    }
  }

  /// Validate Hedera account ID format (0.0.123456)
  bool _isValidHederaAccountId(String accountId) {
    final regex = RegExp(r'^0\.0\.[0-9]+$');
    return regex.hasMatch(accountId);
  }
}
