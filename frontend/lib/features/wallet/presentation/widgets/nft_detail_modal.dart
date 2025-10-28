import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../trading/data/models/trade_models.dart';
import '../../../shared/presentation/widgets/custom_button.dart';

class NftDetailModal extends StatelessWidget {
  final Trade trade;
  final VoidCallback onPurchase;

  const NftDetailModal({
    super.key,
    required this.trade,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.grey900 : AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getMutedTextColor(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NFT Image
                  CachedNetworkImage(
                    imageUrl: trade.animal?.imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: AppTheme.grey100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: AppTheme.grey100,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: AppTheme.getMutedTextColor(context),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NFT Name
                        Text(
                          trade.animal?.name ?? 'Unnamed NFT',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Token ID
                        if (trade.animal?.tokenId != null)
                          Text(
                            'Token #${trade.animal!.tokenId}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: AppTheme.getMutedTextColor(context),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Price
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.grey800 : AppTheme.grey50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Price',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.getMutedTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${trade.price} ${trade.currency}',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description (Note: TradeAnimal doesn't have description field)
                        // If you need description, fetch it from the full Animal object

                        // Properties
                        Text(
                          'Properties',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            if (trade.animal?.species != null)
                              _buildPropertyChip(
                                  'Species', trade.animal!.species),
                            if (trade.animal?.breed != null)
                              _buildPropertyChip('Breed', trade.animal!.breed!),
                            if (trade.animal?.age != null)
                              _buildPropertyChip(
                                  'Age', '${trade.animal!.age} years'),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Seller Info
                        if (trade.seller != null) ...[
                          Text(
                            'Seller',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isDark ? AppTheme.grey800 : AppTheme.grey50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    trade.seller!.firstName[0].toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${trade.seller!.firstName} ${trade.seller!.lastName}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.getTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Purchase Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.grey900 : AppTheme.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.getBorderColorFromContext(context),
                ),
              ),
            ),
            child: SafeArea(
              child: CustomButton(
                onPressed: onPurchase,
                text: 'Purchase for ${trade.price} ${trade.currency}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
