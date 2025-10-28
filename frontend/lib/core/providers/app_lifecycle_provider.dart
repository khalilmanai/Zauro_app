import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/wallet/providers/wallet_provider.dart';

/// Provider that manages app lifecycle and auto-loads data
final appLifecycleProvider = Provider<AppLifecycleManager>((ref) {
  return AppLifecycleManager(ref);
});

class AppLifecycleManager {
  final Ref _ref;
  bool _isInitializing = false;
  String? _lastUserId;

  AppLifecycleManager(this._ref) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to auth state changes
    _ref.listen(authNotifierProvider, (previous, next) {
      _handleAuthStateChange(previous, next);
    });
  }

  void _handleAuthStateChange(dynamic previous, dynamic next) {
    final currentUserId = next.user?.id;

    // When user logs in successfully (and it's a new user or first login)
    if (currentUserId != null &&
        currentUserId != _lastUserId &&
        !_isInitializing) {
      _lastUserId = currentUserId;
      _onUserLogin();
    }

    // When user logs out
    if (next.user == null && previous?.user != null) {
      _lastUserId = null;
      _onUserLogout();
    }
  }

  /// Called when user successfully logs in
  Future<void> _onUserLogin() async {
    if (_isInitializing) {
      print('⏭️ Wallet initialization already in progress, skipping...');
      return;
    }

    _isInitializing = true;
    try {
      print('🚀 Starting wallet initialization for user $_lastUserId');

      // Auto-create or load wallet
      await _initializeWallet();

      // Load wallet balance
      await _loadWalletBalance();

      print('✅ Wallet initialization complete');
    } catch (e) {
      // Log error but don't block the app
      print('❌ Error initializing user data: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Called when user logs out
  void _onUserLogout() {
    // Clear wallet data
    _ref.read(walletProvider.notifier).clear();
    _ref.read(walletBalanceProvider.notifier).clear();
  }

  /// Initialize wallet (create if doesn't exist, load if exists)
  Future<void> _initializeWallet() async {
    try {
      print('🔄 Initializing wallet...');
      // Try to get existing wallet first
      await _ref.read(walletProvider.notifier).getMyWallet();
      print('✅ Wallet loaded successfully');
    } catch (e) {
      print('⚠️ Error getting wallet: $e');
      // If wallet doesn't exist, create one
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not found') ||
          errorMsg.contains('404') ||
          errorMsg.contains('no wallet')) {
        try {
          print('🆕 Creating new wallet...');
          await _ref.read(walletProvider.notifier).createWallet();
          print('✅ Wallet created successfully');
        } catch (createError) {
          print('❌ Error creating wallet: $createError');
          // Don't rethrow - wallet creation failure shouldn't block login
        }
      }
    }
  }

  /// Load wallet balance
  Future<void> _loadWalletBalance() async {
    try {
      print('🔄 Loading wallet balance...');
      await _ref.read(walletBalanceProvider.notifier).getBalance();
      print('✅ Wallet balance loaded successfully');
    } catch (e) {
      print('❌ Error loading wallet balance: $e');
      // Log more details for debugging
      if (e is Exception) {
        print('Exception details: ${e.runtimeType}');
      }
    }
  }

  /// Manually refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      _ref.read(walletProvider.notifier).refresh(),
      _ref.read(walletBalanceProvider.notifier).refresh(),
    ]);
  }
}
