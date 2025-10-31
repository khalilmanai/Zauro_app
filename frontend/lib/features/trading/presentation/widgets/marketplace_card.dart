import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/trade_models.dart';
import 'status_badge.dart';

class MarketplaceCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback? onTap;
  final bool disableBuy;
  final VoidCallback? onBuy;
  final bool showOwnerBadge;

  const MarketplaceCard({
    super.key,
    required this.trade,
    this.onTap,
    this.disableBuy = false,
    this.onBuy,
    this.showOwnerBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorderColorFromContext(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: trade.animal?.imageUrl != null
                        ? Image.network(
                            trade.animal!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppTheme.grey100,
                              child: const Center(child: Icon(Icons.pets_rounded, size: 40, color: Colors.grey)),
                            ),
                          )
                        : Container(
                            color: AppTheme.grey100,
                            child: const Center(child: Icon(Icons.pets_rounded, size: 40, color: Colors.grey)),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: StatusBadge(status: trade.status, compact: true),
                ),
                if (showOwnerBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Your Listing',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trade.animal?.name ?? 'Animal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${trade.price} ${trade.currency}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (trade.animal?.species != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.grey100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trade.animal!.species,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: AppTheme.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.getMutedTextColor(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _formatSellerName(trade),
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: AppTheme.getMutedTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: disableBuy ? null : onBuy,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        disableBuy ? 'Your Listing' : 'Buy Now',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatSellerName(Trade trade) {
    if (trade.seller?.firstName != null) {
      return '@${trade.seller!.firstName}';
    }
    if (trade.sellerId.isNotEmpty) {
      return trade.sellerId.length > 8 ? '${trade.sellerId.substring(0, 8)}...' : trade.sellerId;
    }
    return 'Unknown Seller';
  }
}


