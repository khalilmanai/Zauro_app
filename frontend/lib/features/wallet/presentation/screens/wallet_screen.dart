import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/enhanced_loader.dart' as Enhanced;
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../providers/wallet_provider.dart';
import '../widgets/transfer_hbar_dialog.dart';
import '../widgets/receive_qr_dialog.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
    });
  }

  void _loadWalletData() {
    ref.read(walletProvider.notifier).getMyWallet();
    ref.read(walletBalanceProvider.notifier).getBalance();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final balanceState = ref.watch(walletBalanceProvider);
    final hasWallet = ref.watch(hasWalletProvider);

    final isLoading = walletState.isLoading || balanceState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Wallet',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshWallet,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        child: RefreshIndicator(
          onRefresh: _refreshWallet,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasWallet)
                  _buildCreateWalletCard()
                else ...[
                  _buildBalanceCard(balanceState),
                  SizedBox(height: 24),
                  _buildWalletActions(),
                  SizedBox(height: 32),
                  _buildRecentTransactions(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshWallet() async {
    await Future.wait([
      ref.read(walletProvider.notifier).refresh(),
      ref.read(walletBalanceProvider.notifier).refresh(),
    ]);
  }

  Widget _buildCreateWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.getMediumShadow(),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Create Your Wallet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a secure Hedera wallet to start trading animals and managing your digital assets.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.grey600,
            ),
          ),
          SizedBox(height: 24),
          CustomButton(
            onPressed: () => _createWallet(),
            text: 'Create Wallet',
            isLoading: ref.watch(walletProvider).isLoading,
          ),
        ],
      ),
    );
  }

  Future<void> _createWallet() async {
    try {
      await ref.read(walletProvider.notifier).createWallet();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wallet created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create wallet: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildBalanceCard(AsyncValue balanceState) {
    return PremiumCard(
      gradient: AppTheme.getNeonPrimaryGradient(
        direction: GradientDirection.topLeft,
      ),
      borderRadius: 24,
      padding: const EdgeInsets.all(28),
      customShadows: AppTheme.getPrimaryNeonGlow(isDark: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Hedera Network',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.savings_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Hedera',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          balanceState.when(
            data: (balance) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance?.formattedHbarBalance ?? '0.00000000 HBAR',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$0.00 USD',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Enhanced.ShimmerLoader(
                  child: Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Enhanced.ShimmerLoader(
                  child: Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            error: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error loading balance',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try refreshing',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          balanceState.when(
            data: (balance) => Row(
              children: [
                Expanded(
                    child: _buildBalanceItem(
                        'HBAR', balance?.hbar ?? '0.00000000')),
                SizedBox(width: 16),
                Expanded(
                    child: _buildBalanceItem('ZAU', balance?.zau ?? '0.00')),
              ],
            ),
            loading: () => Row(
              children: [
                Expanded(child: _buildBalanceItem('HBAR', '...')),
                SizedBox(width: 16),
                Expanded(child: _buildBalanceItem('ZAU', '...')),
              ],
            ),
            error: (_, __) => Row(
              children: [
                Expanded(child: _buildBalanceItem('HBAR', 'Error')),
                SizedBox(width: 16),
                Expanded(child: _buildBalanceItem('ZAU', 'Error')),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100))
        .fadeIn(duration: AppTheme.mediumAnimation)
        .slideY(begin: 0.3, end: 0, curve: AppTheme.smoothTransition);
  }

  Widget _buildBalanceItem(String currency, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currency,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            title: 'Send',
            icon: Icons.arrow_upward,
            color: AppTheme.primaryColor,
            onTap: () => _showTransferDialog(),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            title: 'Receive',
            icon: Icons.arrow_downward,
            color: AppTheme.successColor,
            onTap: () => _showReceiveDialog(),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            title: 'History',
            icon: Icons.history,
            color: AppTheme.accentColor,
            onTap: () => context.push('/wallet/history'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.getLightShadow(),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full transaction history
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // TODO: Replace with actual transaction data
        _buildEmptyTransactions(),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.receipt_long,
              size: 40,
              color: AppTheme.grey400,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.grey500),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    final wallet = ref.read(walletProvider).value;
    if (wallet == null) return;

    showDialog(
      context: context,
      builder: (context) => TransferHbarDialog(
        wallet: wallet,
        onTransferComplete: () {
          _refreshWallet();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showReceiveDialog() {
    final wallet = ref.read(walletProvider).value;
    if (wallet == null) return;

    showDialog(
      context: context,
      builder: (context) => ReceiveQrDialog(
        hederaAccountId: wallet.hederaAccountId,
      ),
    );
  }
}
