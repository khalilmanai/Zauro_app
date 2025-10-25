import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../providers/animals_provider.dart';

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
    final myAnimalsState = ref.watch(myAnimalsProvider);

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
        isLoading: myAnimalsState.isLoading,
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
                _buildFilterChip('Cows', false),
                const SizedBox(width: 8),
                _buildFilterChip('Goats', false),
                const SizedBox(width: 8),
                _buildFilterChip('Sheep', false),
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
    return AnimatedContainer(
      duration: AppTheme.fastAnimation,
      curve: AppTheme.quickTransition,
      child: Material(
        elevation: isSelected ? 4 : 0,
        borderRadius: BorderRadius.circular(20),
        shadowColor: isSelected
            ? AppTheme.getPrimaryColor(context).withOpacity(0.3)
            : Colors.transparent,
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              // TODO: Implement filter logic
            });
          },
          backgroundColor: Colors.transparent,
          selectedColor: Color.lerp(
            Colors.white,
            AppTheme.getPrimaryColor(context).withOpacity(0.1),
            0.8,
          ),
          side: BorderSide(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getBorderColor(context),
            width: isSelected ? 1.5 : 1,
          ),
          checkmarkColor: AppTheme.getPrimaryColor(context),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.grey700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          showCheckmark: true,
          elevation: 0,
          pressElevation: 0,
        ),
      ),
    ).animate().scaleXY(
          begin: isSelected ? 1.0 : 0.95,
          end: 1.0,
          duration: AppTheme.fastAnimation,
          curve: AppTheme.quickTransition,
        );
  }

  Widget _buildAnimalsList() {
    // TODO: Replace with actual data from provider
    final hasAnimals = false;

    if (!hasAnimals) {
      return _buildEmptyState();
    }

    // TODO: Implement when animals data is available
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: PremiumCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(40),
          gradient: AppTheme.getRainbowGradient(
            opacity: 0.1,
            direction: GradientDirection.topCenter,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PremiumCard(
                borderRadius: 100,
                gradient: AppTheme.getRainbowGradient(
                  opacity: 0.2,
                  direction: GradientDirection.topLeft,
                ),
                padding: const EdgeInsets.all(32),
                hasElevation: false,
                child: Icon(
                  Icons.pets,
                  size: 80,
                  color: AppTheme.getPrimaryColor(context),
                ),
              ).animate(delay: Duration(milliseconds: 200)).scaleXY(
                  begin: 0.8,
                  end: 1.0,
                  duration: AppTheme.mediumAnimation,
                  curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                'No Animals Yet',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryColor(context),
                ),
              )
                  .animate(delay: Duration(milliseconds: 300))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 16),
              Text(
                'Start your journey by adding your first animal to the marketplace and explore the world of blockchain-based pet trading.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.grey600,
                  height: 1.5,
                ),
              )
                  .animate(delay: Duration(milliseconds: 400))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 40),
              GradientButton(
                text: 'Add Your First Animal',
                onPressed: () => context.push('/animals/add'),
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 24),
                gradient: AppTheme.getNeonPrimaryGradient(
                  direction: GradientDirection.topLeft,
                ),
                size: ButtonSize.large,
              )
                  .animate(delay: Duration(milliseconds: 500))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100))
        .fadeIn(duration: AppTheme.slowAnimation);
  }
}
