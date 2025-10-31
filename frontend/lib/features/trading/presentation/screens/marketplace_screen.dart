import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/enhanced_loader.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../animals/data/models/animal_models.dart';
import '../../data/models/trade_models.dart';
import '../../providers/trading_provider.dart';
import '../widgets/marketplace_card.dart';
import '../widgets/trade_confirmation_dialog.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedFilter = 'All';
  String _sortBy = 'newest';
  bool _isGridView = true;

  final List<String> _filters = ['All', 'Cows', 'Goats', 'Sheep', 'Other'];
  final List<String> _sortOptions = ['newest', 'name'];

  @override
  bool get wantKeepAlive => true;

  String _welcomeText() {
    final authState = ref.watch(authNotifierProvider);
    final firstName = authState.user?.firstName;
    if (firstName != null && firstName.trim().isNotEmpty) {
      return 'Welcome Back, ${firstName.trim()}!';
    }
    return 'Welcome Back!';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceProvider.notifier).getAvailableTrades();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final screenData = MediaQuery.of(context);
    final screenWidth = screenData.size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    final isMobile = screenWidth <= 768;

    ref.listen(marketplaceProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marketplace error: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Enable swipe to open drawer from left edge
        if (details.delta.dx > 12 && details.globalPosition.dx < 20) {
          _scaffoldKey.currentState?.openDrawer();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        drawer: _buildAppDrawer(context),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(isDesktop, isTablet),
              _buildMarketplaceContent(
                ref.watch(marketplaceProvider),
                isDesktop,
                isTablet,
                isMobile,
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(isDesktop, isTablet),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDesktop, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 200 : (isTablet ? 180 : 160),
      pinned: true,
      floating: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: null,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: isDesktop ? 22 : (isTablet ? 20 : 18),
            ),
          ),
        ),
        SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: isDesktop ? 22 : (isTablet ? 20 : 18),
            ),
          ),
        ),
        SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: isDesktop ? 24 : (isTablet ? 22 : 20),
                          ),
                        ),
                        tooltip: 'Menu',
                      ),
                      SizedBox(width: isDesktop ? 12 : (isTablet ? 8 : 6)),
                      Text(
                        'Livestock Marketplace',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 4)),
                  Text(
                    'Discover premium livestock for trade and purchase',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 16 : (isTablet ? 14 : 13),
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
                  _buildSearchBar(isDesktop, isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search animals, breeds, or species...',
          hintStyle: GoogleFonts.poppins(
            fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.primaryColor,
              size: isDesktop ? 24 : (isTablet ? 22 : 20),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isDesktop ? 18 : (isTablet ? 16 : 14),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          ref.read(marketplaceProvider.notifier).searchMarketplace(value);
        },
        onChanged: (value) {
          if (value.isEmpty) {
            ref.read(marketplaceProvider.notifier).getAvailableTrades();
          }
        },
      ),
    );
  }

  SliverList _buildMarketplaceContent(
    AsyncValue<List<Animal>> animalsState,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          child: Column(
            children: [
              SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
              _buildControlsSection(isDesktop, isTablet),
              SizedBox(height: isDesktop ? 16 : (isTablet ? 14 : 12)),
            ],
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
              vertical: isDesktop ? 24 : (isTablet ? 20 : 16),
            ),
            child: animalsState.when(
              data: (animals) {
                // Filter by species
                List<Animal> filtered = animals.where((a) => 
                  _matchesFilterAnimal(a, _selectedFilter)
                ).toList();

                // Apply sorting
                if (_sortBy == 'newest') {
                  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                } else if (_sortBy == 'name') {
                  filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                }

                if (filtered.isNotEmpty) {
                  return _isGridView
                      ? _buildAnimalGrid(filtered, isDesktop, isTablet)
                      : _buildAnimalList(filtered, isDesktop, isTablet);
                }
                // No animals
                return _buildEmptyState(isDesktop, isTablet);
              },
              loading: () => _buildLoadingState(isDesktop, isTablet),
              error: (error, stack) {
                debugPrint('⚠️ Marketplace error: $error');
                return _buildErrorState(error, isDesktop, isTablet);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAnimalGrid(List<Animal> animals, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final spacing = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: isDesktop ? 0.75 : (isTablet ? 0.8 : 0.85),
      ),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        final animal = animals[index];
        final auth = ref.read(authNotifierProvider);
        final myId = auth.user?.id;
        final disableBuy = myId != null && (myId == animal.ownerId);
        return _buildAnimalCardSimple(animal, isDesktop, isTablet);
      },
    );
  }

  Widget _buildAnimalCardSimple(Animal a, bool isDesktop, bool isTablet) {
    return PremiumCard(
      onTap: () => context.push('/animals/${a.id}'),
      borderRadius: isDesktop ? 16 : (isTablet ? 12 : 8),
      enableHoverAnimation: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isDesktop ? 16 : (isTablet ? 12 : 8)),
                  topRight: Radius.circular(isDesktop ? 16 : (isTablet ? 12 : 8)),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    color: AppTheme.grey100,
                    child: a.imageUrl != null
                        ? Image.network(a.imageUrl!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(Icons.pets,
                                color: AppTheme.grey400, size: isDesktop ? 48 : 40),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isDesktop ? 12 : (isTablet ? 10 : 8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${a.species}${a.breed != null ? ' • ${a.breed}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${a.age ?? '-'} yrs',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('View',
                              style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimalTileSimple(Animal a, bool isDesktop, bool isTablet) {
    return PremiumCard(
      onTap: () => context.push('/animals/${a.id}'),
      borderRadius: isDesktop ? 16 : (isTablet ? 12 : 8),
      enableHoverAnimation: true,
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(isDesktop ? 12 : (isTablet ? 8 : 6)),
            child: Container(
              width: isDesktop ? 120 : (isTablet ? 100 : 80),
              height: isDesktop ? 120 : (isTablet ? 100 : 80),
              color: AppTheme.grey100,
              child: a.imageUrl != null
                  ? Image.network(a.imageUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(Icons.pets,
                          color: AppTheme.grey400, size: isDesktop ? 32 : 28)),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  a.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${a.species}${a.breed != null ? ' • ${a.breed}' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 12 : 11,
                    color: AppTheme.grey600,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    a.description ?? 'No description provided.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 12 : 11,
                      color: AppTheme.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAnimalList(List<Animal> animals, bool isDesktop, bool isTablet) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: animals.length,
      separatorBuilder: (_, __) =>
          SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
      itemBuilder: (context, index) {
        final animal = animals[index];
        final auth = ref.read(authNotifierProvider);
        final myId = auth.user?.id;
        final disableBuy = myId != null && (myId == animal.ownerId);
        return _buildAnimalCardSimple(animal, isDesktop, isTablet);
      },
    );
  }

  Future<void> _openTradeDialog(Trade trade) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => TradeConfirmationDialog(trade: trade),
    );
    if (ok == true) {
      if (!mounted) return;
      await ref.read(marketplaceProvider.notifier).refresh();
    }
  }

  Widget _buildControlsSection(bool isDesktop, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Livestock',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 4)),
                    Text(
                      'Browse and discover premium animals for trade',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                        color: AppTheme.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildViewToggle(isDesktop, isTablet),
              SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : 8)),
              _buildSortDropdown(isDesktop, isTablet),
            ],
          ),
          SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
          _buildFilterChips(isDesktop, isTablet),
        ],
      ),
    );
  }

  Widget _buildViewToggle(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 40 : (isTablet ? 36 : 32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          Container(
            width: 1,
            height: 20,
            color: AppTheme.grey200,
          ),
          _buildToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        child: Container(
          width: isDesktop ? 40 : (isTablet ? 36 : 32),
          height: isDesktop ? 40 : (isTablet ? 36 : 32),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppTheme.grey600,
            size: isDesktop ? 18 : (isTablet ? 16 : 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 40 : (isTablet ? 36 : 32),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: false,
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppTheme.grey600,
            size: isDesktop ? 20 : (isTablet ? 18 : 16),
          ),
          items: _sortOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                _getSortLabel(option),
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey800,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortBy = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding:
                EdgeInsets.only(right: isDesktop ? 12 : (isTablet ? 10 : 8)),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) =>
                  setState(() => _selectedFilter = filter),
              selectedColor: AppTheme.primaryColor.withOpacity(0.12),
              checkmarkColor: AppTheme.primaryColor,
              showCheckmark: false,
              elevation: 0,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
                width: 1.5,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 20 : (isTablet ? 16 : 12),
                vertical: isDesktop ? 12 : (isTablet ? 10 : 8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDesktop, bool isTablet) {
    if (isDesktop) return const SizedBox.shrink();

    return FloatingActionButton(
      onPressed: () => context.push('/animals/add'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_rounded),
    );
  }

  Drawer _buildAppDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _welcomeText(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _drawerItem(
                    context,
                    icon: Icons.storefront_rounded,
                    label: 'Marketplace',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/marketplace');
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.add_circle_rounded,
                    label: 'List Animal',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/animals/add');
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.pets_rounded,
                    label: 'My Animals',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/animals');
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/wallet');
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.help_rounded,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/help');
                    },
                  ),
                ],
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).logout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.1),
                        foregroundColor: AppTheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? AppTheme.primaryColor : AppTheme.grey800,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.circle,
                color: Colors.white,
                size: 8,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.grey400,
            ),
      onTap: onTap,
    );
  }

  Widget _buildLoadingState(bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);
    final spacing = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: isDesktop ? 0.75 : (isTablet ? 0.8 : 0.85),
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return ShimmerLoader(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                          color: AppTheme.grey300,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      height: 14,
                      width: 80,
                      decoration: BoxDecoration(
                          color: AppTheme.grey300,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Container(
                      height: 36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: AppTheme.grey300,
                          borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isDesktop, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: isDesktop ? 60 : (isTablet ? 50 : 40),
              color: AppTheme.error,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Unable to Load',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.w700,
              color: AppTheme.grey800,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 50 : (isTablet ? 40 : 30)),
            child: Text(
              'Please check your connection and try again',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                color: AppTheme.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(marketplaceProvider.notifier).getAvailableTrades(),
            icon: Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : (isTablet ? 28 : 24),
                vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDesktop, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isDesktop ? 160 : (isTablet ? 140 : 120),
            height: isDesktop ? 160 : (isTablet ? 140 : 120),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: isDesktop ? 60 : (isTablet ? 50 : 40),
              color: AppTheme.grey400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Animals For Sale',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
              fontWeight: FontWeight.w700,
              color: AppTheme.grey800,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : (isTablet ? 60 : 40)),
            child: Text(
              'Try adjusting your search or filters to find what you\'re looking for.',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                color: AppTheme.grey600,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _searchController.clear();
              });
              ref.read(marketplaceProvider.notifier).getAvailableTrades();
            },
            icon: Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'Reset Filters',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : (isTablet ? 28 : 24),
                vertical: isDesktop ? 16 : (isTablet ? 14 : 12),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String option) {
    switch (option) {
      case 'newest':
        return 'Newest';
      case 'name':
        return 'Name A-Z';
      default:
        return option;
    }
  }
}

// --- Filtering helpers (single source of truth) ---
extension on _MarketplaceScreenState {
  bool _matchesFilterAnimal(Animal a, String label) {
    if (label == 'All') return true;
    final speciesMap = {
      'Cows': 'COW',
      'Goats': 'GOAT',
      'Sheep': 'SHEEP',
    };
    final targetSpecies = speciesMap[label] ?? label.toUpperCase();
    return a.species == targetSpecies;
  }

  bool _matchesFilterTrade(Trade t, String label) {
    if (label == 'All') return true;
    final speciesCode = (t.animal?.species ?? '').toUpperCase();
    final display = (t.animal?.displaySpecies ?? '').toUpperCase();
    return _matchSpeciesLabel(speciesCode, display, label);
  }

  bool _matchSpeciesLabel(String speciesCode, String display, String label) {
    final known = {'COW', 'GOAT', 'SHEEP'};
    final normalizedLabel = label.toUpperCase();
    if (normalizedLabel == 'OTHER') {
      final isKnownCode = known.contains(speciesCode);
      final isKnownDisplay =
          known.any((k) => display.contains(k.substring(0, 3)));
      final hasAny = speciesCode.isNotEmpty || display.isNotEmpty;
      return hasAny && !(isKnownCode || isKnownDisplay);
    }
    String? expected;
    if (normalizedLabel.startsWith('COW')) expected = 'COW';
    if (normalizedLabel.startsWith('GOAT')) expected = 'GOAT';
    if (normalizedLabel.startsWith('SHEEP')) expected = 'SHEEP';
    if (expected == null) return true; // unknown label -> no-op
    if (speciesCode == expected) return true;
    return display.startsWith(expected);
  }
}
