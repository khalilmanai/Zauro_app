import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../data/models/wallet_models.dart';

class WalletInfoCard extends ConsumerWidget {
  const WalletInfoCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);
    final balanceState = ref.watch(walletBalanceProvider);
    final didState = ref.watch(didProvider);

    return walletState.when(
      data: (wallet) {
        if (wallet == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Header
            _buildWalletHeader(),

            const SizedBox(height: 24),

            // Wallet Details Cards
            _buildWalletDetails(wallet),

            const SizedBox(height: 24),

            // Balance Cards
            _buildBalanceCards(balanceState),

            const SizedBox(height: 24),

            // DID Card
            _buildDidCard(didState),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildWalletHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppTheme.getNeonPrimaryGradient(
          direction: GradientDirection.topLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.getPrimaryNeonGlow(isDark: false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hedera Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Secure',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Blockchain Protected',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletDetails(WalletResponse wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hedera Account ID - Most important info
          _buildInfoRow(
            label: 'Hedera Account ID',
            value: wallet.hederaAccountId,
            icon: Icons.fingerprint,
            copyValue: wallet.hederaAccountId,
            highlighted: true,
          ),

          const SizedBox(height: 16),

          // Wallet ID (masked)
          _buildInfoRow(
            label: 'Wallet ID',
            value: _maskWalletId(wallet.id),
            icon: Icons.vpn_key,
            copyValue: wallet.id,
          ),

          const SizedBox(height: 16),

          // Public Key
          _buildInfoRow(
            label: 'Public Key',
            value: _formatPublicKey(wallet.publicKey),
            icon: Icons.key,
            copyValue: wallet.publicKey,
          ),

          const SizedBox(height: 16),

          // Creation Date
          _buildDateInfo(
            label: 'Created',
            date: wallet.createdAt,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(AsyncValue<WalletBalance?> balanceState) {
    return balanceState.when(
      data: (balance) => Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              title: 'HBAR Balance',
              amount: balance?.displayHbar ?? '0.00',
              currency: 'ℏ',
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBalanceCard(
              title: 'ZAU Balance',
              amount: balance?.displayZau ?? '0.00',
              currency: 'ZAU',
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: [
          Expanded(child: _buildBalanceCardSkeleton()),
          const SizedBox(width: 16),
          Expanded(child: _buildBalanceCardSkeleton()),
        ],
      ),
      error: (error, stackTrace) => Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              title: 'HBAR Balance',
              amount: 'Error',
              currency: 'ℏ',
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBalanceCard(
              title: 'ZAU Balance',
              amount: 'Error',
              currency: 'ZAU',
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required String amount,
    required String currency,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  currency == 'ℏ' ? Icons.currency_bitcoin : Icons.toll,
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                currency,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: AppTheme.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 28,
            width: 120,
            decoration: BoxDecoration(
              color: AppTheme.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDidCard(AsyncValue<String?> didState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.perm_identity,
                size: 20,
                color: AppTheme.grey600,
              ),
              const SizedBox(width: 8),
              Text(
                'Decentralized ID (DID)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          didState.when(
            data: (did) => did != null
                ? _buildInfoRow(
                    label: 'DID',
                    value: _formatDid(did),
                    icon: Icons.perm_identity,
                    copyValue: did,
                    isDid: true,
                  )
                : _buildEmptyDidState(),
            loading: () => _buildDidSkeleton(),
            error: (error, stackTrace) => _buildDidErrorState(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required String copyValue,
    bool isDid = false,
    bool highlighted = false,
  }) {
    return CopyableInfoRow(
      label: label,
      value: value,
      copyValue: copyValue,
      isDid: isDid,
      highlighted: highlighted,
    );
  }

  Widget _buildDateInfo({
    required String label,
    required DateTime date,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.grey900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  Widget _buildEmptyDidState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.grey500,
          ),
          const SizedBox(width: 8),
          Text(
            'No DID available',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDidSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDidErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Error loading DID',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Wallet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.grey600,
            ),
          ),
        ],
      ),
    );
  }

  String _maskWalletId(String walletId) {
    if (walletId.length <= 8) return walletId;
    return '${walletId.substring(0, 4)}...${walletId.substring(walletId.length - 4)}';
  }

  String _formatPublicKey(String publicKey) {
    if (publicKey.length <= 16) return publicKey;
    return '${publicKey.substring(0, 8)}...${publicKey.substring(publicKey.length - 8)}';
  }

  String _formatDid(String did) {
    if (did.length <= 32) return did;
    return '${did.substring(0, 16)}...${did.substring(did.length - 16)}';
  }
}

class CopyableInfoRow extends StatefulWidget {
  final String label;
  final String value;
  final String copyValue;
  final bool isDid;
  final bool highlighted;

  const CopyableInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.copyValue,
    this.isDid = false,
    this.highlighted = false,
  });

  @override
  State<CopyableInfoRow> createState() => _CopyableInfoRowState();
}

class _CopyableInfoRowState extends State<CopyableInfoRow> {
  bool _isCopying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.highlighted ? const EdgeInsets.all(12) : null,
      decoration: widget.highlighted
          ? BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.highlighted)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.verified,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    Text(
                      widget.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: widget.highlighted
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.highlighted
                            ? AppTheme.primaryColor
                            : AppTheme.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: widget.isDid
                      ? GoogleFonts.robotoMono(
                          fontSize: widget.highlighted ? 15 : 14,
                          fontWeight: widget.highlighted
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: widget.highlighted
                              ? AppTheme.grey900
                              : AppTheme.grey900,
                        )
                      : GoogleFonts.poppins(
                          fontSize: widget.highlighted ? 15 : 14,
                          fontWeight: widget.highlighted
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: widget.highlighted
                              ? AppTheme.grey900
                              : AppTheme.grey900,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _copyToClipboard,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isCopying
                    ? AppTheme.successColor.withOpacity(0.1)
                    : widget.highlighted
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.grey100,
                borderRadius: BorderRadius.circular(8),
                border: _isCopying
                    ? Border.all(color: AppTheme.successColor.withOpacity(0.3))
                    : null,
              ),
              child: Icon(
                _isCopying ? Icons.check : Icons.copy,
                size: 16,
                color: _isCopying
                    ? AppTheme.successColor
                    : widget.highlighted
                        ? AppTheme.primaryColor
                        : AppTheme.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    setState(() {
      _isCopying = true;
    });

    await Clipboard.setData(ClipboardData(text: widget.copyValue));

    // Show feedback
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isCopying = false;
      });
    }
  }
}
