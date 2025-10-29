import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../providers/trading_provider.dart';
import '../../data/models/trade_models.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedFilter = 'All';
  String _sortBy = 'newest';
  bool _isGridView = true;

  final List<String> _filters = ['All', 'Cows', 'Goats', 'Sheep', 'Other'];
  final List<String> _sortOptions = [
    'newest',
    'price_low',
    'price_high',
    'name'
  ];

  @override
  bool get wantKeepAlive => true;

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
            content: Text('Error: ${next.error}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(isDesktop, isTablet),
            ];
          },
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : (isTablet ? 24 : 16),
              vertical: isDesktop ? 24 : (isTablet ? 16 : 12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildControlsSection(isDesktop, isTablet),
                SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
                Flexible(
                  child: _buildMarketplaceContent(
                    ref.watch(marketplaceProvider),
                    isDesktop,
                    isTablet,
                    isMobile,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(bool isDesktop, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 260 : (isTablet ? 220 : 200),
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                AppTheme.primaryColor.withOpacity(0.7),
                AppTheme.primaryColor.withOpacity(0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 36 : (isTablet ? 28 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            isDesktop ? 18 : (isTablet ? 16 : 14)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: isDesktop ? 36 : (isTablet ? 32 : 28),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 20 : (isTablet ? 16 : 12)),
                      Expanded(
                        child: Text(
                          'Livestock Marketplace',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 4)),
                  Text(
                    'Discover premium livestock for trade and purchase',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 28 : (isTablet ? 24 : 20)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(
          fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
          color: AppTheme.grey900,
        ),
        decoration: InputDecoration(
          hintText: 'Search animals, breeds, or species...',
          hintStyle: GoogleFonts.poppins(
            fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
            color: AppTheme.grey500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.grey500,
            size: isDesktop ? 24 : (isTablet ? 22 : 20),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
            vertical: isDesktop ? 20 : (isTablet ? 18 : 16),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            ref.read(marketplaceProvider.notifier).searchMarketplace(value);
          } else {
            ref.read(marketplaceProvider.notifier).getAvailableTrades();
          }
        },
        onChanged: (value) {
          if (value.isEmpty) {
            ref.read(marketplaceProvider.notifier).getAvailableTrades();
          }
        },
      ),
    );
  }

  Widget _buildControlsSection(bool isDesktop, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildViewToggle(isDesktop, isTablet),
            ),
            SizedBox(width: isDesktop ? 24 : (isTablet ? 20 : 16)),
            Expanded(
              flex: 3,
              child: _buildSortDropdown(isDesktop, isTablet),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 24 : (isTablet ? 20 : 16)),
        _buildFilterChips(isDesktop, isTablet),
      ],
    );
  }

  Widget _buildViewToggle(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 60 : (isTablet ? 56 : 52),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.grey600,
              size: isDesktop ? 26 : (isTablet ? 24 : 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(bool isDesktop, bool isTablet) {
    return Container(
      height: isDesktop ? 60 : (isTablet ? 56 : 52),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 24 : 20),
        border: Border.all(color: AppTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppTheme.grey600,
            size: isDesktop ? 32 : (isTablet ? 28 : 24),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
          ),
          items: _sortOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                _getSortLabel(option),
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 17 : (isTablet ? 16 : 15),
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
    return SizedBox(
      height: isDesktop ? 60 : (isTablet ? 56 : 52),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding:
                EdgeInsets.only(right: isDesktop ? 16 : (isTablet ? 14 : 12)),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
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
                width: 2,
              ),
              backgroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
                  width: 2,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : (isTablet ? 20 : 16),
                vertical: isDesktop ? 14 : (isTablet ? 12 : 10),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketplaceContent(
    AsyncValue<List<Trade>> marketplaceState,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return marketplaceState.when(
      data: (trades) {
        final filteredTrades = _filterAndSortTrades(trades);
        if (filteredTrades.isEmpty) {
          return _buildEmptyState(isDesktop, isTablet);
        }
        return _isGridView
            ? _buildGridView(filteredTrades, isDesktop, isTablet, isMobile)
            : _buildListView(filteredTrades, isDesktop, isTablet, isMobile);
      },
      loading: () => _buildLoadingState(isDesktop, isTablet),
      error: (error, stack) => _buildErrorState(error, isDesktop, isTablet),
    );
  }

  List<Trade> _filterAndSortTrades(List<Trade> trades) {
    List<Trade> filtered = trades.where((trade) {
      if (_selectedFilter == 'All') return true;
      return trade.animal?.species?.toLowerCase() ==
          _selectedFilter.toLowerCase();
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return a.price.compareTo(b.price);
        case 'price_high':
          return b.price.compareTo(a.price);
        case 'name':
          return (a.animal?.name ?? '').compareTo(b.animal?.name ?? '');
        case 'newest':
        default:
          return 0;
      }
    });

    return filtered;
  }

  Widget _buildGridView(
    List<Trade> trades,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final spacing = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final aspectRatio = isDesktop ? 0.75 : (isTablet ? 0.78 : 0.82);

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeCard(trade, isDesktop, isTablet, isMobile);
      },
    );
  }

  Widget _buildListView(
    List<Trade> trades,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: trades.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: isDesktop ? 28 : (isTablet ? 24 : 20)),
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeListItem(trade, isDesktop, isTablet, isMobile);
      },
    );
  }

  Widget _buildTradeCard(
    Trade trade,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final animal = trade.animal;

    return PremiumCard(
      onTap: () => context.push('/trade/${trade.id}'),
      borderRadius: isDesktop ? 28 : (isTablet ? 24 : 20),
      enableHoverAnimation: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(isDesktop ? 28 : (isTablet ? 24 : 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 28 : (isTablet ? 24 : 20)),
                topRight:
                    Radius.circular(isDesktop ? 28 : (isTablet ? 24 : 20)),
              ),
              child: Container(
                height: isDesktop ? 260 : (isTablet ? 220 : 190),
                width: double.infinity,
                color: AppTheme.grey100,
                child: animal?.imageUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            animal!.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    isDesktop ? 16 : (isTablet ? 14 : 12),
                                vertical: isDesktop ? 10 : (isTablet ? 8 : 6),
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(trade.status)
                                    .withOpacity(0.95),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                trade.displayStatus,
                                style: GoogleFonts.poppins(
                                  fontSize:
                                      isDesktop ? 14 : (isTablet ? 13 : 12),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getSpeciesIcon(animal?.species ?? 'OTHER'),
                              size: isDesktop ? 56 : (isTablet ? 48 : 42),
                              color: AppTheme.grey400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              animal?.displaySpecies ?? 'Other',
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                                color: AppTheme.grey500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isDesktop ? 28 : (isTablet ? 24 : 20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal?.name ?? 'Unknown Animal',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                      fontWeight: FontWeight.w800,
                      color: AppTheme.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${animal?.displaySpecies ?? 'Other'}${animal?.breed != null ? ' • ${animal!.breed}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 16 : (isTablet ? 15 : 14),
                      color: AppTheme.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${trade.price} ${trade.currency}',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 26 : (isTablet ? 24 : 22),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: isDesktop ? 20 : (isTablet ? 18 : 16),
                        color: AppTheme.grey400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * (trade.hashCode % 5))).fadeIn(
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildTradeListItem(
    Trade trade,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
  ) {
    final animal = trade.animal;

    return PremiumCard(
      onTap: () => context.push('/trade/${trade.id}'),
      borderRadius: isDesktop ? 28 : (isTablet ? 24 : 20),
      enableHoverAnimation: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(isDesktop ? 28 : (isTablet ? 24 : 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(isDesktop ? 24 : (isTablet ? 20 : 16)),
              child: Container(
                width: isDesktop ? 180 : (isTablet ? 160 : 140),
                height: isDesktop ? 180 : (isTablet ? 160 : 140),
                color: AppTheme.grey100,
                child: animal?.imageUrl != null
                    ? Image.network(
                        animal!.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getSpeciesIcon(animal?.species ?? 'OTHER'),
                              size: isDesktop ? 36 : (isTablet ? 32 : 28),
                              color: AppTheme.grey400,
                            ),
                            SizedBox(height: 10),
                            Text(
                              animal?.displaySpecies ?? 'Other',
                              style: GoogleFonts.poppins(
                                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                                color: AppTheme.grey500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            SizedBox(width: isDesktop ? 28 : (isTablet ? 24 : 20)),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 24 : (isTablet ? 20 : 18),
                  horizontal: isDesktop ? 20 : (isTablet ? 18 : 16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal?.name ?? 'Unknown Animal',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
                        fontWeight: FontWeight.w900,
                        color: AppTheme.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${animal?.displaySpecies ?? 'Other'}${animal?.breed != null ? ' • ${animal!.breed}' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 17 : (isTablet ? 16 : 15),
                        color: AppTheme.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${trade.price} ${trade.currency}',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 28 : (isTablet ? 26 : 24),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 16 : (isTablet ? 14 : 12),
                            vertical: isDesktop ? 10 : (isTablet ? 8 : 6),
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(trade.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Text(
                            trade.displayStatus,
                            style: GoogleFonts.poppins(
                              fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(trade.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 50 * (trade.hashCode % 5))).fadeIn(
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildLoadingState(bool isDesktop, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: isDesktop ? 80 : (isTablet ? 70 : 60),
              height: isDesktop ? 80 : (isTablet ? 70 : 60),
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 4,
              ),
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Loading Marketplace...',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 24 : (isTablet ? 22 : 20),
              color: AppTheme.grey600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            padding: EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: isDesktop ? 90 : (isTablet ? 70 : 60),
              color: AppTheme.error,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Unable to Load Marketplace',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 28 : (isTablet ? 24 : 22),
              fontWeight: FontWeight.w800,
              color: AppTheme.grey800,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 70 : (isTablet ? 50 : 40)),
            child: Text(
              'Please check your connection and try again',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                color: AppTheme.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(marketplaceProvider.notifier).getAvailableTrades(),
            icon: Icon(Icons.refresh_rounded, size: 24),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 36 : 32),
                vertical: isDesktop ? 22 : (isTablet ? 20 : 18),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
            width: isDesktop ? 240 : (isTablet ? 200 : 160),
            height: isDesktop ? 240 : (isTablet ? 200 : 160),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.grey300,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.store_mall_directory_rounded,
              size: isDesktop ? 100 : (isTablet ? 80 : 70),
              color: AppTheme.grey400,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'No Animals Found',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
              fontWeight: FontWeight.w900,
              color: AppTheme.grey800,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 100 : (isTablet ? 80 : 60)),
            child: Text(
              'No animals match your current filters. Try adjusting your search or check back later for new listings.',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 19 : (isTablet ? 17 : 15),
                color: AppTheme.grey600,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _searchController.clear();
              });
              ref.read(marketplaceProvider.notifier).getAvailableTrades();
            },
            icon: Icon(Icons.refresh_rounded, size: 24),
            label: Text(
              'Reset Filters',
              style: GoogleFonts.poppins(
                fontSize: isDesktop ? 18 : (isTablet ? 16 : 15),
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 36 : 32),
                vertical: isDesktop ? 22 : (isTablet ? 20 : 18),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
        return 'Newest First';
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'name':
        return 'Name: A to Z';
      default:
        return option;
    }
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'LISTED':
        return AppTheme.primaryColor;
      case 'PENDING':
        return AppTheme.warning;
      case 'IN_PROGRESS':
        return AppTheme.info;
      case 'COMPLETED':
        return AppTheme.success;
      case 'CANCELLED':
        return AppTheme.grey600;
      case 'FAILED':
        return AppTheme.error;
      default:
        return AppTheme.grey600;
    }
  }
}
