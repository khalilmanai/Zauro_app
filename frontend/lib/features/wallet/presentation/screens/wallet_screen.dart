import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/services/biometric_auth_service.dart';
import 'package:zauro_marketplace/features/wallet/data/models/wallet_models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/data/repositories/auth_repository.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/receive_qr_dialog.dart';
import '../widgets/fund_wallet_dialog.dart';
import '../widgets/enhanced_send_dialog.dart';
import '../widgets/qr_scanner_widget.dart';
import 'nft_marketplace_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isAuthorized = false;
  bool _authAttempted = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Require biometric authentication to access wallet
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _authenticateAndLoad();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticateAndLoad() async {
    final auth = BiometricAuthService();
    final ok =
        await auth.authenticate(reason: 'Authenticate to access your wallet');
    if (!mounted) return;
    if (!ok) {
      setState(() => _authAttempted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access denied')),
      );
      return;
    }

    setState(() {
      _isAuthorized = true;
      _authAttempted = true;
    });

    // Load wallet data on successful authorization
    Future.microtask(() {
      print('🚀 WalletScreen initState - Loading wallet data...');
      ref.read(walletProvider.notifier).getMyWallet();
      ref.read(walletBalanceProvider.notifier).getBalance();
      ref.read(didProvider.notifier).getMyDid();
    });
  }

  Future<void> _authenticateWithPassword() async {
    final authState = ref.read(authNotifierProvider);
    final email = authState.user?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account email available')),
      );
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your account password')),
      );
      return;
    }

    // Attempt non-destructive password verification
    final repository = ref.read(authRepositoryProvider);
    final ok =
        await repository.verifyPassword(email: email, password: password);
    if (ok) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
      setState(() {
        _isAuthorized = true;
        _authAttempted = true;
      });
      // Load after password verification
      await _refreshWallet();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password verification failed')),
      );
    }
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify with Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Account password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: _authenticateWithPassword,
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshWallet() async {
    print('🔄 WalletScreen - Refreshing wallet data...');
    await Future.wait([
      ref.read(walletProvider.notifier).refresh(),
      ref.read(walletBalanceProvider.notifier).refresh(),
      ref.read(didProvider.notifier).refresh(),
    ]);
  }

  void _showReceiveDialog() {
    final wallet = ref.read(walletProvider).value;
    if (wallet == null) {
      print('❌ Cannot show receive dialog - no wallet');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReceiveQrDialog(
        hederaAccountId: wallet.hederaAccountId,
      ),
    );
  }

  void _showFundDialog() {
    final wallet = ref.read(walletProvider).value;
    if (wallet == null) {
      print('❌ Cannot show fund dialog - no wallet');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => FundWalletDialog(
        wallet: wallet,
        onFundComplete: _refreshWallet,
      ),
    );
  }

  void _showSendDialog() {
    final wallet = ref.read(walletProvider).value;
    if (wallet == null) {
      print('❌ Cannot show send dialog - no wallet');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => EnhancedSendDialog(
        wallet: wallet,
        onTransferComplete: () {
          _refreshWallet();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showTransactionHistory() {
    context.push('/wallet/history');
  }

  void _showNFTMarketplace() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NftMarketplaceScreen(),
      ),
    );
  }

  void _openQrScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScannerWidget(
          title: 'Scan QR Code',
          onScanned: (code) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('QR Code Scanned'),
                content: Text('Code: $code'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Copy'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Wallet'),
        ),
        body: Center(
          child: _authAttempted
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Wallet locked',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Authenticate to access your wallet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _authenticateAndLoad,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: const Text('Unlock Wallet'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showPasswordDialog,
                      child: const Text('Use password instead'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    final walletState = ref.watch(walletProvider);
    final balanceState = ref.watch(walletBalanceProvider);
    final didState = ref.watch(didProvider);

    final isLoading =
        walletState.isLoading && balanceState.isLoading && didState.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'Wallet',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openQrScanner,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan QR',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshWallet,
          child: ListView(
            padding: EdgeInsets.only(
              left: isTablet ? 24 : 20,
              right: isTablet ? 24 : 20,
              top: isTablet ? 16 : 12,
              bottom: 100,
            ),
            children: [
              // Balance Header
              _BalanceHeader(
                balanceState: balanceState,
                walletState: walletState,
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 28 : 24),

              // Quick Actions
              _QuickActions(
                isTablet: isTablet,
                onShowFundDialog: _showFundDialog,
                onShowSendDialog: _showSendDialog,
                onShowReceiveDialog: _showReceiveDialog,
                onShowNFTMarketplace: _showNFTMarketplace,
                onShowTransactionHistory: _showTransactionHistory,
              ),

              SizedBox(height: isTablet ? 28 : 24),

              // Assets Section
              _AssetsSection(
                balanceState: balanceState,
                isTablet: isTablet,
                onRefresh: _refreshWallet,
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Wallet Details
              _WalletDetailsSection(
                walletState: walletState,
                didState: didState,
                isTablet: isTablet,
              ),

              SizedBox(height: isTablet ? 24 : 20),

              // Transactions Card
              _TransactionsCard(isTablet: isTablet),
            ],
          ),
        ),
      ),
    );
  }
}

// Balance Header with Public Key Display
class _BalanceHeader extends ConsumerWidget {
  final AsyncValue<WalletBalance?> balanceState;
  final AsyncValue<Wallet?> walletState;
  final bool isTablet;

  const _BalanceHeader({
    required this.balanceState,
    required this.walletState,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Debug information
    walletState.when(
      data: (wallet) {
        print('🎯 _BalanceHeader - Wallet state data: $wallet');
        if (wallet != null) {
          print('🎯 _BalanceHeader - Public key: ${wallet.publicKey}');
          print(
              '🎯 _BalanceHeader - Public key length: ${wallet.publicKey.length}');
          print(
              '🎯 _BalanceHeader - Public key isEmpty: ${wallet.publicKey.isEmpty}');
        } else {
          print('🎯 _BalanceHeader - Wallet is null');
        }
      },
      loading: () => print('🎯 _BalanceHeader - Wallet loading...'),
      error: (error, stack) =>
          print('🎯 _BalanceHeader - Wallet error: $error'),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.scaffoldBackgroundColor,
            AppTheme.getCardBackground(context).withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 32 : 24,
            isTablet ? 60 : 40,
            isTablet ? 32 : 24,
            isTablet ? 20 : 16,
          ),
          child: Column(
            children: [
              Text(
                'Total Balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: mutedColor,
                ),
              ),

              SizedBox(height: isTablet ? 12 : 10),

              // Balance Display
              balanceState.when(
                data: (balance) {
                  final total = balance?.totalBalance ?? 0.0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        total.toStringAsFixed(2),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: isTablet ? 52 : 44,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'ℏ',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: isTablet ? 28 : 24,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '••••••',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: isTablet ? 52 : 44,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'ℏ',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '--.--',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: isTablet ? 52 : 44,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'ℏ',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: isTablet ? 28 : 24,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 14 : 12),

              // USD Value
              balanceState.when(
                data: (balance) {
                  final total = balance?.totalBalance ?? 0.0;
                  return Text(
                    '≈ \$${(total * 0.05).toStringAsFixed(2)} USD',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w500,
                      color: mutedColor,
                    ),
                  );
                },
                loading: () => Text(
                  '≈ \$--.-- USD',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w500,
                    color: mutedColor.withOpacity(0.5),
                  ),
                ),
                error: (error, stack) => Text(
                  '≈ \$--.-- USD',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w500,
                    color: mutedColor.withOpacity(0.3),
                  ),
                ),
              ),

              SizedBox(height: isTablet ? 20 : 16),

              // Public Key Display with enhanced debugging
              walletState.when(
                data: (wallet) {
                  print(
                      '🔄 _BalanceHeader - Building PublicKeyDisplay with wallet: $wallet');

                  if (wallet == null) {
                    print(
                        '❌ _BalanceHeader - Wallet is null, showing no wallet message');
                    return _NoWalletMessage(isTablet: isTablet);
                  }

                  if (wallet.publicKey.isEmpty) {
                    print('❌ _BalanceHeader - Public key is empty string');
                    return _NoPublicKeyMessage(isTablet: isTablet);
                  }

                  print(
                      '✅ _BalanceHeader - Public key found: ${wallet.publicKey}');
                  return _PublicKeyDisplay(
                    publicKey: wallet.publicKey,
                    isTablet: isTablet,
                  );
                },
                loading: () {
                  print('🔄 _BalanceHeader - Wallet loading state');
                  return _PublicKeyLoading(isTablet: isTablet);
                },
                error: (error, stack) {
                  print('❌ _BalanceHeader - Wallet error state: $error');
                  return _WalletErrorState(error: error, isTablet: isTablet);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// No Wallet Message
class _NoWalletMessage extends StatelessWidget {
  final bool isTablet;

  const _NoWalletMessage({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wallet_rounded,
            size: isTablet ? 18 : 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              'No wallet found',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// No Public Key Message
class _NoPublicKeyMessage extends StatelessWidget {
  final bool isTablet;

  const _NoPublicKeyMessage({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.vpn_key_off_rounded,
            size: isTablet ? 18 : 16,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              'Public key not available',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wallet Error State
class _WalletErrorState extends StatelessWidget {
  final Object error;
  final bool isTablet;

  const _WalletErrorState({required this.error, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: isTablet ? 18 : 16,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load wallet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: isTablet ? 12 : 11,
                    color: mutedColor.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Public Key Loading State
class _PublicKeyLoading extends StatelessWidget {
  final bool isTablet;

  const _PublicKeyLoading({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.vpn_key_rounded,
            size: isTablet ? 18 : 16,
            color: mutedColor.withOpacity(0.5),
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: Text(
              'Loading public key...',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w500,
                color: mutedColor.withOpacity(0.5),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 8 : 6),
          SizedBox(
            width: isTablet ? 18 : 16,
            height: isTablet ? 18 : 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: mutedColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// Public Key Display with QR Code and Security Features
class _PublicKeyDisplay extends StatefulWidget {
  final String publicKey;
  final bool isTablet;

  const _PublicKeyDisplay({
    required this.publicKey,
    required this.isTablet,
  });

  @override
  State<_PublicKeyDisplay> createState() => _PublicKeyDisplayState();
}

class _PublicKeyDisplayState extends State<_PublicKeyDisplay> {
  bool _showQrCode = false;
  bool _obscureText = true;

  String _truncatePublicKey(String key) {
    if (key.length <= 16) return key;
    final start = key.substring(0, 8);
    final end = key.substring(key.length - 8);
    return '$start...$end';
  }

  String _getDisplayText() {
    if (_obscureText) {
      return '•' * 20; // Show dots when obscured
    }
    return _truncatePublicKey(widget.publicKey);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.publicKey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Public Key copied!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      children: [
        // Public Key Row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 16 : 12,
            vertical: widget.isTablet ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.vpn_key_rounded,
                size: widget.isTablet ? 18 : 16,
                color: mutedColor,
              ),
              SizedBox(width: widget.isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  _getDisplayText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: widget.isTablet ? 14 : 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: _obscureText ? null : 'Monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              // Eye Icon for Show/Hide
              IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  size: widget.isTablet ? 18 : 16,
                  color: mutedColor,
                ),
                tooltip: _obscureText ? 'Show Public Key' : 'Hide Public Key',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              // Copy Icon
              IconButton(
                onPressed: _copyToClipboard,
                icon: Icon(
                  Icons.copy_rounded,
                  size: widget.isTablet ? 18 : 16,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Copy Public Key',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: widget.isTablet ? 8 : 6),
              // QR Code Toggle
              IconButton(
                onPressed: () {
                  setState(() {
                    _showQrCode = !_showQrCode;
                  });
                },
                icon: Icon(
                  _showQrCode ? Icons.qr_code_2_rounded : Icons.qr_code_rounded,
                  size: widget.isTablet ? 18 : 16,
                  color: theme.colorScheme.primary,
                ),
                tooltip: _showQrCode ? 'Hide QR Code' : 'Show QR Code',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        SizedBox(height: widget.isTablet ? 16 : 12),

        // QR Code Display
        if (_showQrCode)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Public Key QR Code',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: widget.isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: widget.isTablet ? 16 : 12),
                // QR Code
                Container(
                  padding: EdgeInsets.all(widget.isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.publicKey,
                    version: QrVersions.auto,
                    size: widget.isTablet ? 160 : 120,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: widget.isTablet ? 12 : 8),
                Text(
                  'Scan to share public key',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Quick Actions
class _QuickActions extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onShowFundDialog;
  final VoidCallback onShowSendDialog;
  final VoidCallback onShowReceiveDialog;
  final VoidCallback onShowNFTMarketplace;
  final VoidCallback onShowTransactionHistory;

  const _QuickActions({
    required this.isTablet,
    required this.onShowFundDialog,
    required this.onShowSendDialog,
    required this.onShowReceiveDialog,
    required this.onShowNFTMarketplace,
    required this.onShowTransactionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 8,
        vertical: isTablet ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            label: 'Fund',
            icon: Icons.add_circle_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: onShowFundDialog,
            isTablet: isTablet,
          ),
          _ActionButton(
            label: 'Send',
            icon: Icons.arrow_upward_rounded,
            color: Theme.of(context).colorScheme.tertiary,
            onTap: onShowSendDialog,
            isTablet: isTablet,
          ),
          _ActionButton(
            label: 'Receive',
            icon: Icons.arrow_downward_rounded,
            color: Theme.of(context).colorScheme.secondary,
            onTap: onShowReceiveDialog,
            isTablet: isTablet,
          ),
          _ActionButton(
            label: 'Trade',
            icon: Icons.swap_horiz_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: onShowNFTMarketplace,
            isTablet: isTablet,
          ),
          _ActionButton(
            label: 'History',
            icon: Icons.receipt_long_rounded,
            color: Theme.of(context).colorScheme.primary,
            onTap: onShowTransactionHistory,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }
}

// Action Button
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isTablet;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: isTablet ? 24 : 22),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isTablet ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Assets Section
class _AssetsSection extends StatelessWidget {
  final AsyncValue<WalletBalance?> balanceState;
  final bool isTablet;
  final VoidCallback onRefresh;

  const _AssetsSection({
    required this.balanceState,
    required this.isTablet,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assets',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: isTablet ? 19 : 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: theme.colorScheme.primary,
                size: isTablet ? 22 : 20,
              ),
              tooltip: 'Refresh',
            ),
          ],
        ),
        SizedBox(height: isTablet ? 14 : 12),
        balanceState.when(
          data: (balance) => _AssetsList(balance: balance, isTablet: isTablet),
          loading: () => _LoadingCard(isTablet: isTablet),
          error: (_, __) => _ErrorCard(title: 'Assets', isTablet: isTablet),
        ),
      ],
    );
  }
}

// Assets List
class _AssetsList extends StatelessWidget {
  final WalletBalance? balance;
  final bool isTablet;

  const _AssetsList({
    required this.balance,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final hbar = balance?.displayHbar ?? '0.00';
    final zau = balance?.displayZau ?? '0.00';

    return Column(
      children: [
        _AssetRow(
          name: 'HBAR',
          amount: hbar,
          symbol: 'ℏ',
          icon: Icons.currency_bitcoin,
          color: Theme.of(context).colorScheme.primary,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _AssetRow(
          name: 'ZAU',
          amount: zau,
          symbol: 'ZAU',
          icon: Icons.toll_rounded,
          color: Theme.of(context).colorScheme.tertiary,
          isTablet: isTablet,
        ),
      ],
    );
  }
}

// Asset Row
class _AssetRow extends StatelessWidget {
  final String name;
  final String amount;
  final String symbol;
  final IconData icon;
  final Color color;
  final bool isTablet;

  const _AssetRow({
    required this.name,
    required this.amount,
    required this.symbol,
    required this.icon,
    required this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    // Safe amount parsing
    final amountValue = double.tryParse(amount) ?? 0.0;
    final usdValue = (amountValue * 0.05).toStringAsFixed(2);

    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 14 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isTablet ? 26 : 24),
          ),
          SizedBox(width: isTablet ? 16 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  '≈ \$$usdValue',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: isTablet ? 13 : 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(height: isTablet ? 4 : 3),
              Text(
                symbol,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isTablet ? 12 : 11,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Transactions Card
class _TransactionsCard extends StatelessWidget {
  final bool isTablet;

  const _TransactionsCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/wallet/history'),
                child: Text(
                  'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          _EmptyTransactions(isTablet: isTablet),
        ],
      ),
    );
  }
}

// Empty Transactions
class _EmptyTransactions extends StatelessWidget {
  final bool isTablet;

  const _EmptyTransactions({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final mutedColor = AppTheme.getMutedTextColor(context);

    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: isTablet ? 48 : 40,
            color: mutedColor.withOpacity(0.3),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'No Transactions Yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: mutedColor,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isTablet ? 13 : 12,
              color: mutedColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading Card
class _LoadingCard extends StatelessWidget {
  final bool isTablet;

  const _LoadingCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return Container(
      height: isTablet ? 140 : 120,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

// Error Card
class _ErrorCard extends StatelessWidget {
  final String title;
  final bool isTablet;

  const _ErrorCard({
    required this.title,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: isTablet ? 48 : 40,
            color: mutedColor.withOpacity(0.5),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Error loading $title',
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Wallet Details Section (Wallet ID, Hedera Account ID, Public Key, DID)
class _WalletDetailsSection extends StatelessWidget {
  final AsyncValue<Wallet?> walletState;
  final AsyncValue<String?> didState;
  final bool isTablet;

  const _WalletDetailsSection({
    required this.walletState,
    required this.didState,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).colorScheme.outline;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: isTablet ? 16 : 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: isTablet ? 14 : 12),
          walletState.when(
            data: (wallet) {
              if (wallet == null) {
                return Text(
                  'No wallet found',
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
                );
              }
              return Column(
                children: [
                  _InfoRow(
                    label: 'Hedera Account ID',
                    value: wallet.hederaAccountId,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 10),
                  _InfoRow(
                    label: 'Wallet ID',
                    value: _maskEnds(wallet.id, 6),
                    fullCopyValue: wallet.id,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 10),
                  _InfoRow(
                    label: 'Public Key',
                    value: _maskEnds(wallet.publicKey, 10),
                    fullCopyValue: wallet.publicKey,
                    isTablet: isTablet,
                  ),
                  SizedBox(height: isTablet ? 12 : 10),
                  didState.when(
                    data: (did) => _InfoRow(
                      label: 'Decentralized ID',
                      value:
                          did == null || did.isEmpty ? '—' : _maskEnds(did, 8),
                      fullCopyValue: did ?? '',
                      isTablet: isTablet,
                    ),
                    loading: () => _InfoRow(
                      label: 'Decentralized ID',
                      value: 'Loading…',
                      isTablet: isTablet,
                      isLoading: true,
                    ),
                    error: (_, __) => _InfoRow(
                      label: 'Decentralized ID',
                      value: 'Failed to load',
                      isTablet: isTablet,
                      isError: true,
                    ),
                  ),
                ],
              );
            },
            loading: () => Row(
              children: [
                SizedBox(
                  width: isTablet ? 18 : 16,
                  height: isTablet ? 18 : 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: mutedColor),
                ),
                SizedBox(width: 8),
                Text('Loading wallet…',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: mutedColor)),
              ],
            ),
            error: (error, _) => Text(
              'Failed to load wallet: $error',
              style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
            ),
          ),
        ],
      ),
    );
  }

  String _maskEnds(String value, int keep) {
    if (value.length <= keep * 2) return value;
    return '${value.substring(0, keep)}...${value.substring(value.length - keep)}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final String? fullCopyValue;
  final bool isTablet;
  final bool isLoading;
  final bool isError;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isTablet,
    this.fullCopyValue,
    this.isLoading = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      fontSize: isTablet ? 14 : 13,
      fontWeight: FontWeight.w600,
      color: isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
      fontFamily: 'Monospace',
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: isTablet ? 12 : 11,
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(value, style: valueStyle, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        SizedBox(width: isTablet ? 8 : 6),
        if (isLoading)
          SizedBox(
            width: isTablet ? 18 : 16,
            height: isTablet ? 18 : 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: mutedColor),
          )
        else if (fullCopyValue != null && fullCopyValue!.isNotEmpty)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullCopyValue ?? ''));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied')),
              );
            },
            icon: Icon(Icons.copy_rounded,
                size: isTablet ? 18 : 16, color: theme.colorScheme.primary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Copy $label',
          ),
      ],
    );
  }
}
