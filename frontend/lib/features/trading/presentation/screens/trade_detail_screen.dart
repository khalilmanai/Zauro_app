import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../data/models/trade_models.dart';
import '../../providers/trading_provider.dart';
import '../widgets/trade_confirmation_dialog.dart';
import '../../../auth/providers/auth_provider.dart';

class TradeDetailScreen extends ConsumerWidget {
  final String tradeId;

  const TradeDetailScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeState = ref.watch(tradeProvider(tradeId));
    final auth = ref.watch(authNotifierProvider);
    final currentUserId = auth.user?.id;

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Trade Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
        ),
      ),
      body: LoadingOverlay(
        isLoading: tradeState.isLoading,
        child: tradeState.when(
          data: (trade) {
            if (trade == null) {
              return Center(
                child: Text(
                  'Trade not found',
                  style: GoogleFonts.poppins(color: AppTheme.errorColor),
                ),
              );
            }
            final isOwner = currentUserId == trade.sellerId;
            final canBuy = trade.canBuy && !isOwner;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimalSection(context, trade),
                  _buildTradeInfoSection(context, trade),
                  _buildSellerSection(context, trade),
                  _buildActionSection(context, ref, trade, canBuy, isOwner),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  'Error loading trade',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Retry',
                  onPressed: () => ref
                      .read(tradeProvider(tradeId).notifier)
                      .refresh(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalSection(BuildContext context, Trade trade) {
    final animal = trade.animal;
    if (animal == null) {
      return Container(
        color: AppTheme.white,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Animal information not available',
            style: GoogleFonts.poppins(color: AppTheme.grey600),
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: AppTheme.grey200,
            child: animal.imageUrl != null && animal.imageUrl!.isNotEmpty
                ? Image.network(
                    animal.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.pets, size: 80, color: AppTheme.grey400),
                    ),
                  )
                : Center(
                    child: Icon(Icons.pets, size: 80, color: AppTheme.grey400),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (animal.species.isNotEmpty)
                      _buildInfoChip('Species', animal.displaySpecies),
                    if (animal.breed != null && animal.breed!.isNotEmpty)
                      _buildInfoChip('Breed', animal.breed!),
                    if (animal.age != null)
                      _buildInfoChip(
                        'Age',
                        animal.age == 1
                            ? '1 year'
                            : '${animal.age} years',
                      ),
                    if (animal.gender.isNotEmpty)
                      _buildInfoChip('Gender', animal.displayGender),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTradeInfoSection(BuildContext context, Trade trade) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trade Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 16),
          _buildTradeInfo('Price', '${trade.price.toStringAsFixed(2)} ${trade.currency}'),
          const SizedBox(height: 8),
          _buildTradeInfo('Status', trade.displayStatus),
          const SizedBox(height: 8),
          _buildTradeInfo('Listed Date', dateFormat.format(trade.createdAt)),
          const SizedBox(height: 8),
          if (trade.completedAt != null)
            _buildTradeInfo('Completed Date', dateFormat.format(trade.completedAt!)),
          const SizedBox(height: 8),
          _buildTradeInfo('Trade ID', trade.id.substring(0, 8) + '...'),
        ],
      ),
    );
  }

  Widget _buildTradeInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.grey600),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.grey900,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerSection(BuildContext context, Trade trade) {
    final seller = trade.seller;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller != null ? seller.fullName : 'Seller',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                ),
                Text(
                  seller?.email ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Verified',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    WidgetRef ref,
    Trade trade,
    bool canBuy,
    bool isOwner,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This trade will be executed using atomic swaps for maximum security',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (canBuy)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Buy Now - ${trade.price.toStringAsFixed(2)} ${trade.currency}',
                onPressed: () => _showBuyConfirmation(context, ref, trade),
              ),
            )
          else if (isOwner)
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'This is your listing',
                isOutlined: true,
                onPressed: null,
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Trade ${trade.displayStatus}',
                isOutlined: true,
                onPressed: null,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Message Seller',
                  isOutlined: true,
                  onPressed: () {
                    // TODO: Implement messaging
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Messaging feature coming soon'),
                        backgroundColor: AppTheme.grey600,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Share Trade',
                  isOutlined: true,
                  onPressed: () {
                    // TODO: Implement sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sharing feature coming soon'),
                        backgroundColor: AppTheme.grey600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBuyConfirmation(BuildContext context, WidgetRef ref, Trade trade) {
    showDialog(
      context: context,
      builder: (context) => TradeConfirmationDialog(trade: trade),
    ).then((success) {
      if (success == true && context.mounted) {
        // Refresh trade data after purchase
        ref.read(tradeProvider(tradeId).notifier).refresh();
        // Navigate back if needed
        if (context.canPop()) {
          context.pop();
        }
      }
    });
  }
}
