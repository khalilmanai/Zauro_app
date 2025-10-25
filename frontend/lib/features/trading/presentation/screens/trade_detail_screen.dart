import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';

class TradeDetailScreen extends ConsumerWidget {
  final String tradeId;

  const TradeDetailScreen({super.key, required this.tradeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        isLoading: false, // TODO: Connect to actual loading state
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // TODO: Replace with actual trade data
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnimalSection(),
          _buildTradeInfoSection(),
          _buildSellerSection(),
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildAnimalSection() {
    return Container(
      color: AppTheme.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: AppTheme.grey200,
            child: Center(
              child: Icon(Icons.pets, size: 80, color: AppTheme.grey400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animal Name', // TODO: Use actual animal name
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.grey900,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('Species', 'Dog'),
                    SizedBox(width: 12),
                    _buildInfoChip('Breed', 'Golden Retriever'),
                    SizedBox(width: 12),
                    _buildInfoChip('Age', '3 years'),
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

  Widget _buildTradeInfoSection() {
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
          SizedBox(height: 16),
          _buildTradeInfo('Price', '250.00 HBAR'),
          SizedBox(height: 8),
          _buildTradeInfo('Status', 'Listed'),
          SizedBox(height: 8),
          _buildTradeInfo('Listed Date', '2 days ago'),
          SizedBox(height: 8),
          _buildTradeInfo('Trade ID', tradeId),
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
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.grey900,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerSection() {
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
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seller Name', // TODO: Use actual seller name
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                ),
                Text(
                  'seller@example.com', // TODO: Use actual seller email
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

  Widget _buildActionSection() {
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
                SizedBox(width: 12),
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
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Buy Now - 250.00 HBAR',
              onPressed: () => _showBuyConfirmation(),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Message Seller',
                  isOutlined: true,
                  onPressed: () {
                    // TODO: Implement messaging
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Share Trade',
                  isOutlined: true,
                  onPressed: () {
                    // TODO: Implement sharing
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBuyConfirmation() {
    // TODO: Show buy confirmation dialog and implement purchase flow
  }
}
