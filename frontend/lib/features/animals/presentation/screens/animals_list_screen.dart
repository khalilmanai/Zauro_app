import 'package:flutter/material.dart' hide OutlinedButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../providers/animals_provider.dart';
import '../../data/models/animal_models.dart';

class AnimalsListScreen extends ConsumerStatefulWidget {
  const AnimalsListScreen({super.key});

  @override
  ConsumerState<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends ConsumerState<AnimalsListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  late final ScrollController _scrollController;
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myAnimalsProvider.notifier).getMyAnimals(page: 1, limit: 10);
    });
    _scrollController = ScrollController()
      ..addListener(() {
        final notifier = ref.read(myAnimalsProvider.notifier);
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !ref.read(myAnimalsProvider).isLoading) {
          notifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myAnimalsState = ref.watch(myAnimalsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: 300.ms,
          child: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search animals...',
                    hintStyle: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      if (mounted) setState(() {});
                    });
                  },
                )
              : Text(
                  'My Animals',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0.5,
        shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            icon: AnimatedSwitcher(
              duration: 300.ms,
              child: _isSearching
                  ? const Icon(Icons.close)
                  : const Icon(Icons.search),
            ),
          ),
          IconButton(
            onPressed: () => context.push('/animals/add'),
            icon: const Icon(Icons.add),
            tooltip: 'Add Animal',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'refresh') {
                ref.read(myAnimalsProvider.notifier).refresh();
              } else if (value == 'settings') {
                // Handle settings navigation
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 20),
                    const SizedBox(width: 12),
                    Text('Refresh', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, size: 20),
                    const SizedBox(width: 12),
                    Text('Settings', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isSearching) _buildFilterSection(screenWidth),
          Expanded(
            child: Stack(
              children: [
                _buildAnimalsList(myAnimalsState, screenWidth),
                if (myAnimalsState.isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getPrimaryColor(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilterSection(double screenWidth) {
    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 16),
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildModernFilterChip('All', _selectedFilter == 'All'),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Cows', _selectedFilter == 'Cows'),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Goats', _selectedFilter == 'Goats'),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Sheep', _selectedFilter == 'Sheep'),
                  const SizedBox(width: 8),
                  _buildModernFilterChip('Listed', _selectedFilter == 'Listed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final myAnimalsState = ref.watch(myAnimalsProvider);

    return myAnimalsState.when(
      data: (animals) {
        final total = animals.length;
        final listed = animals.where((a) => a.isListed).length;
        final approved = animals
            .where((a) => a.reviewStatus == AnimalStatus.expertApproved)
            .length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', total.toString()),
            _buildStatItem('Listed', listed.toString()),
            _buildStatItem('Approved', approved.toString()),
          ],
        );
      },
      loading: () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '-', isLoading: true),
          _buildStatItem('Listed', '-', isLoading: true),
          _buildStatItem('Approved', '-', isLoading: true),
        ],
      ),
      error: (error, stackTrace) => const SizedBox(), // Hide stats on error
    );
  }

  Widget _buildStatItem(String label, String value, {bool isLoading = false}) {
    return Column(
      children: [
        if (isLoading)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(bottom: 4),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.getPrimaryColor(context),
              ),
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernFilterChip(String label, bool isSelected) {
    final radius = BorderRadius.circular(20);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          if (_selectedFilter != label) {
            setState(() {
              _selectedFilter = label;
            });
            // Optionally reset to first page for consistency
            ref.read(myAnimalsProvider.notifier).goToPage(1);
          }
        },
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: radius,
            border: Border.all(
              color: isSelected
                  ? AppTheme.getPrimaryColor(context)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ).animate().scale(duration: 200.ms),
              if (isSelected) const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ).animate().scaleXY(
              begin: isSelected ? 0.9 : 1.0,
              end: 1.0,
              duration: 200.ms,
            ),
      ),
    );
  }

  Widget _buildAnimalsList(
      AsyncValue<List<Animal>> myAnimalsState, double screenWidth) {
    return myAnimalsState.when(
      data: (animals) {
        if (animals.isEmpty) {
          return _buildEmptyState();
        }

        // Apply filters
        List<Animal> filteredAnimals = _applyFilters(animals);

        if (filteredAnimals.isEmpty) {
          return _buildEmptyState(
              message: 'No animals match your search criteria.');
        }

        return _buildAnimalsGrid(filteredAnimals, screenWidth);
      },
      loading: () => _buildShimmerGrid(screenWidth),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  List<Animal> _applyFilters(List<Animal> animals) {
    List<Animal> filteredAnimals = animals;

    // Apply category filter
    switch (_selectedFilter) {
      case 'Cows':
        filteredAnimals =
            animals.where((a) => a.species.toUpperCase() == 'COW').toList();
        break;
      case 'Goats':
        filteredAnimals =
            animals.where((a) => a.species.toUpperCase() == 'GOAT').toList();
        break;
      case 'Sheep':
        filteredAnimals =
            animals.where((a) => a.species.toUpperCase() == 'SHEEP').toList();
        break;
      case 'Listed':
        filteredAnimals = animals.where((a) => a.isListed == true).toList();
        break;
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredAnimals = filteredAnimals.where((animal) {
        return animal.name.toLowerCase().contains(query) ||
            animal.species.toLowerCase().contains(query) ||
            (animal.breed?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filteredAnimals;
  }

  Widget _buildAnimalsGrid(List<Animal> animals, double screenWidth) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 0.7 : 0.75;

    return RefreshIndicator.adaptive(
      onRefresh: () => ref.read(myAnimalsProvider.notifier).refresh(),
      color: AppTheme.getPrimaryColor(context),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: animals.length,
        itemBuilder: (context, index) {
          final animal = animals[index];
          return _buildModernAnimalCard(animal, index);
        },
        controller: _scrollController,
      ),
    );
  }

  Widget _buildModernAnimalCard(Animal animal, int index) {
    return PremiumCard(
      onTap: () => context.push('/animals/${animal.id}'),
      borderRadius: 20,
      enableHoverAnimation: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    width: double.infinity,
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: animal.imageUrl != null
                        ? Image.network(
                            animal.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.getPrimaryColor(context),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  _getSpeciesIcon(animal.species),
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              _getSpeciesIcon(animal.species),
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
              ),
              // Status Badges
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: [
                    if (animal.isListed)
                      _buildCompactBadge(
                        'Listed',
                        AppTheme.primaryColor.withOpacity(0.9),
                      ),
                    const Spacer(),
                    _buildCompactBadge(
                      _getStatusText(animal.reviewStatus ??
                          AnimalStatus.pendingExpertReview),
                      _getStatusColor(animal.reviewStatus ??
                          AnimalStatus.pendingExpertReview),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    animal.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${animal.species}${animal.breed != null ? ' • ${animal.breed}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      animal.description ?? 'No description provided.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Footer
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(context)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${animal.age ?? '-'} yrs',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * (index % 5)))
        .fadeIn(
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildCompactBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(double screenWidth) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return PremiumCard(
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 60,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .shimmer(
              duration: 1000.ms,
              delay: Duration(milliseconds: index * 200),
            );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Animals',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your connection and try again',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  text: 'Try Again',
                  onPressed: () =>
                      ref.read(myAnimalsProvider.notifier).refresh(),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.push('/animals/add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Animal',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final notifier = ref.read(myAnimalsProvider.notifier);
    final int page = notifier.currentPage;
    final int totalPages = notifier.totalPages == 0 ? 1 : notifier.totalPages;
    final int limit = notifier.limit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pagination Controls
          Row(
            children: [
              IconButton(
                tooltip: 'Previous Page',
                onPressed: page > 1
                    ? () {
                        ref
                            .read(myAnimalsProvider.notifier)
                            .getMyAnimals(page: page - 1, limit: limit);
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: page > 1
                      ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                      : null,
                ),
                icon: Icon(
                  Icons.chevron_left,
                  color: page > 1
                      ? AppTheme.getPrimaryColor(context)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$page / $totalPages',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Next Page',
                onPressed: page < totalPages
                    ? () {
                        ref
                            .read(myAnimalsProvider.notifier)
                            .getMyAnimals(page: page + 1, limit: limit);
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: page < totalPages
                      ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                      : null,
                ),
                icon: Icon(
                  Icons.chevron_right,
                  color: page < totalPages
                      ? AppTheme.getPrimaryColor(context)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          // Items Per Page
          Row(
            children: [
              Text(
                'Show:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<int>(
                  value: limit,
                  items: const [10, 20, 50]
                      .map((v) => DropdownMenuItem<int>(
                            value: v,
                            child: Text(
                              '$v',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref
                          .read(myAnimalsProvider.notifier)
                          .getMyAnimals(page: 1, limit: v);
                    }
                  },
                  underline: const SizedBox(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Keep existing _buildEmptyState, _getSpeciesIcon, and other helper methods...
  // (They're already well-implemented in your original code)

  Widget _buildEmptyState({String? message}) {
    // Your existing _buildEmptyState implementation
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: PremiumCard(
          borderRadius: 28,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
                message != null ? 'No Results' : 'No Animals Yet',
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
                message ??
                    'Start your journey by adding your first animal to the marketplace and explore the world of blockchain-based pet trading.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              )
                  .animate(delay: Duration(milliseconds: 400))
                  .fadeIn(duration: AppTheme.mediumAnimation)
                  .slideY(begin: 0.3, end: 0),
              if (message == null) ...[
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
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100))
        .fadeIn(duration: AppTheme.slowAnimation);
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toUpperCase()) {
      case 'COW':
        return Icons.agriculture_rounded;
      case 'GOAT':
        return Icons.pets_rounded;
      case 'SHEEP':
        return Icons.eco_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  String _getStatusText(AnimalStatus status) {
    switch (status) {
      case AnimalStatus.expertApproved:
        return 'Approved';
      case AnimalStatus.expertRejected:
        return 'Rejected';
      case AnimalStatus.minted:
        return 'Minted';
      case AnimalStatus.listed:
        return 'Listed';
      case AnimalStatus.pendingExpertReview:
        return 'Pending';
    }
  }

  Color _getStatusColor(AnimalStatus status) {
    switch (status) {
      case AnimalStatus.expertApproved:
        return Colors.green;
      case AnimalStatus.expertRejected:
        return Colors.red;
      case AnimalStatus.minted:
        return Colors.purple;
      case AnimalStatus.listed:
        return AppTheme.primaryColor;
      case AnimalStatus.pendingExpertReview:
        return Colors.amber.shade700;
    }
  }
}
