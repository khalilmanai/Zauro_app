import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';

class AnimalsListScreen extends ConsumerStatefulWidget {
  const AnimalsListScreen({super.key});

  @override
  ConsumerState<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends ConsumerState<AnimalsListScreen> {
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
          'My Animals',
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
            onPressed: () => context.push('/animals/add'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: false, // TODO: Connect to actual loading state
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(child: _buildAnimalsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/animals/add'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: AppTheme.white),
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
                hintText: 'Search animals...',
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
                _buildFilterChip('Listed', false),
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
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
      ),
    );
  }

  Widget _buildAnimalsList() {
    // TODO: Replace with actual data from provider
    final hasAnimals = false;

    if (!hasAnimals) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 0, // TODO: Use actual animal count
      itemBuilder: (context, index) {
        // TODO: Return AnimalCard widget
        return const SizedBox.shrink();
      },
    );
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
              child: const Icon(Icons.pets, size: 60, color: AppTheme.grey400),
            ),
            const SizedBox(height: 24),
            Text(
              'No Animals Yet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your journey by adding your first animal to the marketplace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey500),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Add Your First Animal',
              onPressed: () => context.push('/animals/add'),
              icon: const Icon(Icons.add, color: AppTheme.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
