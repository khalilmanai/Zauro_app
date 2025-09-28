import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
            icon: const Icon(Icons.refresh),
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
                  const SizedBox(height: 24),
                  _buildWalletActions(),
                  const SizedBox(height: 32),
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
        boxShadow: AppTheme.mediumShadow,
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
            child: const Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Your Wallet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a secure Hedera wallet to start trading animals and managing your digital assets.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 24),
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
          const SnackBar(
            content: Text('Wallet created successfully!'),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Hedera',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          balanceState.when(
            data: (balance) => Text(
              balance?.formattedHbarBalance ?? '0.00000000 HBAR',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            loading: () => Text(
              'Loading...',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            error: (_, __) => Text(
              'Error loading balance',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$0.00 USD', // TODO: Add USD conversion
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          balanceState.when(
            data: (balance) => Row(
              children: [
                Expanded(
                    child: _buildBalanceItem(
                        'HBAR', balance?.hbar ?? '0.00000000')),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildBalanceItem('ZAU', balance?.zau ?? '0.00')),
              ],
            ),
            loading: () => Row(
              children: [
                Expanded(child: _buildBalanceItem('HBAR', '...')),
                const SizedBox(width: 16),
                Expanded(child: _buildBalanceItem('ZAU', '...')),
              ],
            ),
            error: (_, __) => Row(
              children: [
                Expanded(child: _buildBalanceItem('HBAR', 'Error')),
                const SizedBox(width: 16),
                Expanded(child: _buildBalanceItem('ZAU', 'Error')),
              ],
            ),
          ),
        ],
      ),
    );
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
          const SizedBox(height: 4),
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
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            title: 'Receive',
            icon: Icons.arrow_downward,
            color: AppTheme.successColor,
            onTap: () => _showReceiveDialog(),
          ),
        ),
        const SizedBox(width: 12),
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
          boxShadow: AppTheme.lightShadow,
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
            const SizedBox(height: 12),
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
        const SizedBox(height: 16),

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
        boxShadow: AppTheme.lightShadow,
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
            child: const Icon(
              Icons.receipt_long,
              size: 40,
              color: AppTheme.grey400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey700,
            ),
          ),
          const SizedBox(height: 8),
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
