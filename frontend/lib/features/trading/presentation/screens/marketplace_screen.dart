import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: false, // TODO: Connect to actual loading state
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(child: _buildMarketplace()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey900),
              decoration: InputDecoration(
                hintText: 'Search marketplace...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.grey500,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.grey500,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 8),
                _buildFilterChip('Dogs', false),
                const SizedBox(width: 8),
                _buildFilterChip('Cats', false),
                const SizedBox(width: 8),
                _buildFilterChip('Birds', false),
                const SizedBox(width: 8),
                _buildFilterChip('Price: Low to High', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filter logic
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
      ),
    );
  }

  Widget _buildMarketplace() {
    // TODO: Replace with actual data from provider
    final hasListings = false;

    if (!hasListings) {
      return _buildEmptyState();
    }

    // TODO: Implement when marketplace data is available
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.store, size: 60, color: AppTheme.grey400),
            ),
            const SizedBox(height: 24),
            Text(
              'No Listings Available',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to list an animal for trading in the marketplace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
