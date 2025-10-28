import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/transfer_hbar_dialog.dart';
import '../widgets/receive_qr_dialog.dart';
import '../widgets/fund_wallet_dialog.dart';
import '../widgets/enhanced_send_dialog.dart';
import '../widgets/qr_scanner_widget.dart';
import 'transaction_history_screen.dart';
import 'nft_marketplace_screen.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin, _WalletScreenMixin {
  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Load wallet data on initialization
    Future.microtask(() {
      ref.read(walletProvider.notifier).getMyWallet();
      ref.read(walletBalanceProvider.notifier).getBalance();
      ref.read(didProvider.notifier).getMyDid();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    final walletState = ref.watch(walletProvider);
    final balanceState = ref.watch(walletBalanceProvider);
    final didState = ref.watch(didProvider);

    final isLoading =
        walletState.isLoading || balanceState.isLoading || didState.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _WalletAppBar(
              balanceState: balanceState,
              isTablet: isTablet,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _WalletContent(
                  walletState: walletState,
                  balanceState: balanceState,
                  didState: didState,
                  isTablet: isTablet,
                  onRefresh: _refreshWallet,
                  onShowFundDialog: _showFundDialog,
                  onShowSendDialog: _showEnhancedSendDialog,
                  onShowReceiveDialog: _showReceiveDialog,
                  onShowNFTMarketplace: _showNFTMarketplace,
                  onShowTransactionHistory: _showTransactionHistory,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mixin to separate business logic from UI
mixin _WalletScreenMixin on ConsumerState<WalletScreen> {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _balanceVisible = true;

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this as TickerProvider,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  Future<void> _refreshWallet() async {
    await Future.wait([
      ref.read(walletProvider.notifier).refresh(),
      ref.read(walletBalanceProvider.notifier).refresh(),
      ref.read(didProvider.notifier).refresh(),
    ]);
  }

  void _copyToClipboard(String label, String value) {
    final theme = Theme.of(context);

    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              '$label copied!',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _maskString(String str, int startChars, int endChars) {
    if (str.length <= startChars + endChars) return str;
    return '${str.substring(0, startChars)}...${str.substring(str.length - endChars)}';
  }

  void _showReceiveDialog() {
    final wallet = ref.read(walletProvider).value;

    if (wallet == null) {
      // Show error if wallet is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wallet not loaded. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
      // Show error if wallet is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wallet not loaded. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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

  void _showEnhancedSendDialog() {
    final wallet = ref.read(walletProvider).value;

    if (wallet == null) {
      // Show error if wallet is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wallet not loaded. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
}

// App Bar Widget
class _WalletAppBar extends ConsumerWidget {
  final AsyncValue balanceState;
  final bool isTablet;

  const _WalletAppBar({
    required this.balanceState,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardBackground(context);

    return SliverAppBar(
      expandedHeight: isTablet ? 280 : 240,
      floating: false,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.scaffoldBackgroundColor,
                cardColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: balanceState.when(
              data: (balance) => _BalanceHeader(
                balance: balance,
                isTablet: isTablet,
              ),
              loading: () => const _LoadingHeader(),
              error: (_, __) => const _ErrorHeader(),
            ),
          ),
        ),
        titlePadding: EdgeInsets.zero,
        title: _AppBarTitle(isTablet: isTablet),
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}

// App Bar Title Widget
class _AppBarTitle extends StatelessWidget {
  final bool isTablet;

  const _AppBarTitle({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            theme.scaffoldBackgroundColor.withOpacity(0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Wallet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: isTablet ? 20 : 17,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const _AppBarActions(),
        ],
      ),
    );
  }
}

// App Bar Actions Widget
class _AppBarActions extends ConsumerWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          onTap: () {},
          isTablet: isTablet,
          isDark: isDark,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        _HeaderIconButton(
          icon: Icons.qr_code_scanner_rounded,
          onTap: () => _openQrScanner(context),
          isTablet: isTablet,
          isDark: isDark,
        ),
      ],
    );
  }

  void _openQrScanner(BuildContext context) {
    // Import the QrScannerWidget
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QrScannerWidget(
          title: 'Scan QR Code',
          onScanned: (code) {
            _handleScannedCode(context, code);
          },
        ),
      ),
    );
  }

  void _handleScannedCode(BuildContext context, String code) {
    // Show options dialog for scanned code
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
                  backgroundColor: AppTheme.success,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}

// Header Icon Button Widget
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isTablet;
  final bool isDark;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 10 : 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface.withOpacity(0.9),
            size: isTablet ? 22 : 20,
          ),
        ),
      ),
    );
  }
}

// Balance Header Widget
class _BalanceHeader extends ConsumerStatefulWidget {
  final dynamic balance;
  final bool isTablet;

  const _BalanceHeader({
    required this.balance,
    required this.isTablet,
  });

  @override
  ConsumerState<_BalanceHeader> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends ConsumerState<_BalanceHeader> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final hbar = widget.balance?.displayHbar ?? '0.00';
    final zau = widget.balance?.displayZau ?? '0.00';
    final total = widget.balance?.totalBalance ?? 0.0;
    final theme = Theme.of(context);
    final mutedColor = AppTheme.getMutedTextColor(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.isTablet ? 32 : 24,
        widget.isTablet ? 80 : 60,
        widget.isTablet ? 32 : 24,
        widget.isTablet ? 20 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Total Balance',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: widget.isTablet ? 15 : 14,
                  fontWeight: FontWeight.w500,
                  color: mutedColor,
                ),
              ),
              SizedBox(width: widget.isTablet ? 12 : 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _balanceVisible = !_balanceVisible;
                  });
                },
                child: Icon(
                  _balanceVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: mutedColor,
                  size: widget.isTablet ? 22 : 20,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 12 : 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _balanceVisible ? total.toStringAsFixed(2) : '••••••',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: widget.isTablet ? 52 : 44,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ℏ',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: widget.isTablet ? 28 : 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isTablet ? 14 : 12),
          Text(
            '≈ \$${(total * 0.05).toStringAsFixed(2)} USD',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: widget.isTablet ? 16 : 15,
              fontWeight: FontWeight.w500,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading Header Widget
class _LoadingHeader extends StatelessWidget {
  const _LoadingHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
        strokeWidth: 2.5,
      ),
    );
  }
}

// Error Header Widget
class _ErrorHeader extends StatelessWidget {
  const _ErrorHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = AppTheme.getMutedTextColor(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: mutedColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Error loading balance',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: mutedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Main Content Widget
class _WalletContent extends StatelessWidget {
  final AsyncValue walletState;
  final AsyncValue balanceState;
  final AsyncValue didState;
  final bool isTablet;
  final VoidCallback onRefresh;
  final VoidCallback onShowFundDialog;
  final VoidCallback onShowSendDialog;
  final VoidCallback onShowReceiveDialog;
  final VoidCallback onShowNFTMarketplace;
  final VoidCallback onShowTransactionHistory;

  const _WalletContent({
    required this.walletState,
    required this.balanceState,
    required this.didState,
    required this.isTablet,
    required this.onRefresh,
    required this.onShowFundDialog,
    required this.onShowSendDialog,
    required this.onShowReceiveDialog,
    required this.onShowNFTMarketplace,
    required this.onShowTransactionHistory,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = isTablet ? 800.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          children: [
            SizedBox(height: isTablet ? 28 : 24),
            _QuickActions(
              isTablet: isTablet,
              onShowFundDialog: onShowFundDialog,
              onShowSendDialog: onShowSendDialog,
              onShowReceiveDialog: onShowReceiveDialog,
              onShowNFTMarketplace: onShowNFTMarketplace,
              onShowTransactionHistory: onShowTransactionHistory,
            ),
            SizedBox(height: isTablet ? 28 : 24),
            _AssetsSection(
              balanceState: balanceState,
              isTablet: isTablet,
              onRefresh: onRefresh,
            ),
            SizedBox(height: isTablet ? 24 : 20),
            _AccountSection(
              walletState: walletState,
              didState: didState,
              isTablet: isTablet,
            ),
            SizedBox(height: isTablet ? 24 : 20),
            _TransactionsCard(isTablet: isTablet),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// Quick Actions Widget
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
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : 8,
          vertical: isTablet ? 18 : 16,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionItem(
              label: 'Fund',
              icon: Icons.add_circle_outline_rounded,
              color: AppTheme.success,
              onTap: onShowFundDialog,
              isTablet: isTablet,
            ),
            _ActionItem(
              label: 'Send',
              icon: Icons.arrow_upward_rounded,
              color: AppTheme.warning,
              onTap: onShowSendDialog,
              isTablet: isTablet,
            ),
            _ActionItem(
              label: 'Receive',
              icon: Icons.arrow_downward_rounded,
              color: AppTheme.info,
              onTap: onShowReceiveDialog,
              isTablet: isTablet,
            ),
            _ActionItem(
              label: 'Trade',
              icon: Icons.swap_horiz_rounded,
              color: AppTheme.primaryColor,
              onTap: onShowNFTMarketplace,
              isTablet: isTablet,
            ),
            _ActionItem(
              label: 'History',
              icon: Icons.receipt_long_rounded,
              color: AppTheme.primaryColor,
              onTap: onShowTransactionHistory,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }
}

// Action Item Widget
class _ActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isTablet;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = AppTheme.getTextColor(context);

    return Flexible(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? 10 : 8,
              horizontal: isTablet ? 8 : 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 10 : 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isTablet ? 24 : 22,
                  ),
                ),
                SizedBox(height: isTablet ? 8 : 6),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Assets Section Widget
class _AssetsSection extends StatelessWidget {
  final AsyncValue balanceState;
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
    final textColor = AppTheme.getTextColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: Column(
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
            data: (balance) => _AssetsList(
              balance: balance,
              isTablet: isTablet,
            ),
            loading: () => _LoadingCard(isTablet: isTablet),
            error: (_, __) => _ErrorCard(
              title: 'Assets',
              isTablet: isTablet,
            ),
          ),
        ],
      ),
    );
  }
}

// Assets List Widget
class _AssetsList extends StatelessWidget {
  final dynamic balance;
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
          color: AppTheme.success,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 10),
        _AssetRow(
          name: 'ZAU',
          amount: zau,
          symbol: 'ZAU',
          icon: Icons.toll_rounded,
          color: AppTheme.warning,
          isTablet: isTablet,
        ),
      ],
    );
  }
}

// Asset Row Widget
class _AssetRow extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);
    final textColor = AppTheme.getTextColor(context);
    final mutedColor = AppTheme.getMutedTextColor(context);

    return Container(
      padding: EdgeInsets.all(isTablet ? 18 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  '≈ \$${(double.parse(amount) * 0.05).toStringAsFixed(2)}',
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

// Account Section Widget
class _AccountSection extends StatelessWidget {
  final AsyncValue walletState;
  final AsyncValue didState;
  final bool isTablet;

  const _AccountSection({
    required this.walletState,
    required this.didState,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);
    final textColor = AppTheme.getTextColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: isTablet ? 17 : 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: isTablet ? 18 : 16),
            walletState.when(
              data: (wallet) => Column(
                children: [
                  _DetailRow(
                    label: 'Hedera Account ID',
                    value: wallet?.hederaAccountId ?? 'N/A',
                    isTablet: isTablet,
                  ),
                  _Divider(isTablet: isTablet),
                  _DetailRow(
                    label: 'Wallet ID',
                    value: _maskString(wallet?.id ?? 'N/A', 6, 6),
                    isTablet: isTablet,
                  ),
                  _Divider(isTablet: isTablet),
                  _DetailRow(
                    label: 'Public Key',
                    value: _maskString(wallet?.publicKey ?? 'N/A', 10, 10),
                    isTablet: isTablet,
                  ),
                ],
              ),
              loading: () => _LoadingRow(isTablet: isTablet),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  String _maskString(String str, int startChars, int endChars) {
    if (str.length <= startChars + endChars) return str;
    return '${str.substring(0, startChars)}...${str.substring(str.length - endChars)}';
  }
}

// Detail Row Widget
class _DetailRow extends ConsumerWidget {
  final String label;
  final String value;
  final bool isTablet;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mutedColor = AppTheme.getMutedTextColor(context);
    final textColor = AppTheme.getTextColor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: isTablet ? 13 : 12,
            color: mutedColor,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 13 : 12,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8),
            GestureDetector(
              onTap: () => _copyToClipboard(context, ref, label, value),
              child: Icon(
                Icons.copy_rounded,
                size: isTablet ? 16 : 14,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(
      BuildContext context, WidgetRef ref, String label, String value) {
    final theme = Theme.of(context);

    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              '$label copied!',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Divider Widget
class _Divider extends StatelessWidget {
  final bool isTablet;

  const _Divider({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final dividerColor = AppTheme.getDividerColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: dividerColor,
      ),
    );
  }
}

// Transactions Card Widget
class _TransactionsCard extends StatelessWidget {
  final bool isTablet;

  const _TransactionsCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);
    final textColor = AppTheme.getTextColor(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
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
      ),
    );
  }
}

// Empty Transactions Widget
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

// Loading Row Widget
class _LoadingRow extends StatelessWidget {
  final bool isTablet;

  const _LoadingRow({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: isTablet ? 3 : 2.5,
        ),
      ),
    );
  }
}

// Loading Card Widget
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
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
          strokeWidth: isTablet ? 3 : 2.5,
        ),
      ),
    );
  }
}

// Error Card Widget
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
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);
    final mutedColor = AppTheme.getMutedTextColor(context);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
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
