import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../shared/presentation/widgets/custom_text_field.dart';
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
      if (next.hasError) {
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
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildStickyHeader(isDesktop, isTablet),
            SliverPadding(
              padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildActionBar(isDesktop, isTablet),
                  SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
                  _buildMarketplaceContent(ref.watch(marketplaceProvider),
                      isDesktop, isTablet, isMobile),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyHeader(bool isDesktop, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 180 : (isTablet ? 160 : 140),
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.accentColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: isDesktop ? 28 : (isTablet ? 24 : 20),
                    ),
                    SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : 8)),
                    Expanded(
                      child: Text(
                        'Marketplace',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 32 : (isTablet ? 26 : 22),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 8 : (isTablet ? 6 : 4)),
                Text(
                  'Discover and trade livestock animals',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isDesktop ? 16 : (isTablet ? 12 : 8)),
                _buildSearchBar(isDesktop, isTablet),
                Spacer(),
              ],
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
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomTextField(
        controller: _searchController,
        label: '',
        hint: 'Search animals, breeds, or species',
        prefixIcon: Icons.search,
        fillColor: Colors.white,
        onChanged: (value) {
          if (value.isNotEmpty) {
            ref.read(marketplaceProvider.notifier).searchMarketplace(value);
          } else {
            ref.read(marketplaceProvider.notifier).getAvailableTrades();
          }
        },
      ),
    );
  }

  Widget _buildActionBar(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildViewToggle(isDesktop, isTablet)),
            SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 8)),
            Expanded(child: _buildSortDropdown(isDesktop, isTablet)),
          ],
        ),
        SizedBox(height: isDesktop ? 16 : (isTablet ? 12 : 8)),
        _buildFiltersRow(isDesktop, isTablet),
      ],
    );
  }

  Widget _buildViewToggle(bool isDesktop, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.grid_view,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
            isDesktop: isDesktop,
            isTablet: isTablet,
          ),
          _buildToggleButton(
            icon: Icons.list,
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 10 : (isTablet ? 8 : 6)),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
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
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(isDesktop ? 10 : 8),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          isExpanded: true,
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 12 : (isTablet ? 10 : 8)),
          items: _sortOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                _getSortLabel(option),
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  fontWeight: FontWeight.w500,
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

  Widget _buildFiltersRow(bool isDesktop, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding:
                EdgeInsets.only(right: isDesktop ? 10 : (isTablet ? 8 : 6)),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.15),
              checkmarkColor: AppTheme.primaryColor,
              showCheckmark: false,
              elevation: isSelected ? 2 : 0,
              labelStyle: GoogleFonts.poppins(
                fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
                width: isSelected ? 2 : 1,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarketplaceContent(AsyncValue<List<Trade>> marketplaceState,
      bool isDesktop, bool isTablet, bool isMobile) {
    return marketplaceState.when(
      data: (trades) {
        if (trades.isEmpty) {
          return _buildEmptyState(isDesktop, isTablet);
        }
        return _isGridView
            ? _buildGridView(trades, isDesktop, isTablet, isMobile)
            : _buildListView(trades, isDesktop, isTablet, isMobile);
      },
      loading: () => _buildLoadingState(isDesktop, isTablet),
      error: (error, stack) => _buildErrorState(error, isDesktop, isTablet),
    );
  }

  Widget _buildGridView(
      List<Trade> trades, bool isDesktop, bool isTablet, bool isMobile) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final childAspectRatio = isDesktop ? 0.8 : (isTablet ? 0.85 : 0.9);
    final spacing = isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeGridCard(trade, isDesktop, isTablet, isMobile);
      },
    );
  }

  Widget _buildListView(
      List<Trade> trades, bool isDesktop, bool isTablet, bool isMobile) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trades.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: isDesktop ? 16 : (isTablet ? 12 : 8)),
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildTradeListCard(trade, isDesktop, isTablet, isMobile);
      },
    );
  }

  Widget _buildTradeGridCard(
      Trade trade, bool isDesktop, bool isTablet, bool isMobile) {
    final animal = trade.animal;

    return PremiumCard(
      onTap: () => context.push('/trade/${trade.id}'),
      borderRadius: isDesktop ? 16 : (isTablet ? 14 : 12),
      enableHoverAnimation: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius:
                    BorderRadius.circular(isDesktop ? 12 : (isTablet ? 10 : 8)),
                image: animal?.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(animal!.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: animal?.imageUrl == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getSpeciesIcon(animal?.species ?? 'OTHER'),
                            size: isDesktop ? 24 : (isTablet ? 20 : 16),
                            color: AppTheme.grey400,
                          ),
                          SizedBox(height: 4),
                          Text(
                            animal?.displaySpecies ?? 'Other',
                            style: GoogleFonts.poppins(
                              fontSize: isDesktop ? 10 : (isTablet ? 9 : 8),
                              color: AppTheme.grey500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal?.name ?? 'Unknown Animal',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 16 : (isTablet ? 14 : 13),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${animal?.displaySpecies ?? 'Other'}${animal?.breed != null ? ' • ${animal!.breed}' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 12 : (isTablet ? 11 : 10),
                    color: AppTheme.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${trade.price} ${trade.currency}',
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 16 : (isTablet ? 14 : 13),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 6 : (isTablet ? 5 : 4),
                        vertical: isDesktop ? 3 : (isTablet ? 2 : 2),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trade.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 6 : (isTablet ? 5 : 4)),
                      ),
                      child: Text(
                        trade.displayStatus,
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 9 : (isTablet ? 8 : 7),
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(trade.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100))
        .fadeIn(duration: Duration(milliseconds: 400));
  }

  Widget _buildTradeListCard(
      Trade trade, bool isDesktop, bool isTablet, bool isMobile) {
    final animal = trade.animal;

    return PremiumCard(
      onTap: () => context.push('/trade/${trade.id}'),
      borderRadius: isDesktop ? 16 : (isTablet ? 14 : 12),
      enableHoverAnimation: true,
      child: Row(
        children: [
          Container(
            width: isDesktop ? 100 : (isTablet ? 80 : 60),
            height: isDesktop ? 100 : (isTablet ? 80 : 60),
            decoration: BoxDecoration(
              color: AppTheme.grey100,
              borderRadius:
                  BorderRadius.circular(isDesktop ? 12 : (isTablet ? 10 : 8)),
              image: animal?.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(animal!.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: animal?.imageUrl == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSpeciesIcon(animal?.species ?? 'OTHER'),
                          size: isDesktop ? 20 : (isTablet ? 18 : 16),
                          color: AppTheme.grey400,
                        ),
                        SizedBox(height: 2),
                        Text(
                          animal?.displaySpecies ?? 'Other',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 8 : (isTablet ? 7 : 6),
                            color: AppTheme.grey500,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SizedBox(width: isDesktop ? 16 : (isTablet ? 12 : 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal?.name ?? 'Unknown Animal',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${animal?.displaySpecies ?? 'Other'}${animal?.breed != null ? ' • ${animal!.breed}' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                    color: AppTheme.grey600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trade.price} ${trade.currency}',
                      style: GoogleFonts.poppins(
                        fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 8 : (isTablet ? 6 : 4),
                        vertical: isDesktop ? 4 : (isTablet ? 3 : 2),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trade.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            isDesktop ? 8 : (isTablet ? 6 : 4)),
                      ),
                      child: Text(
                        trade.displayStatus,
                        style: GoogleFonts.poppins(
                          fontSize: isDesktop ? 10 : (isTablet ? 9 : 8),
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(trade.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100))
        .fadeIn(duration: Duration(milliseconds: 400));
  }

  Widget _buildLoadingState(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Loading marketplace...',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error, bool isDesktop, bool isTablet) {
    return Column(
      children: [
        SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: isDesktop ? 64 : (isTablet ? 48 : 40),
                color: AppTheme.error,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load marketplace',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 18 : (isTablet ? 16 : 14),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '$error',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 14 : (isTablet ? 13 : 12),
                  color: AppTheme.error,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(marketplaceProvider.notifier).getAvailableTrades();
                },
                icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(color: AppTheme.primaryColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDesktop, bool isTablet) {
    return Column(
      children: [
        SizedBox(height: 60),
        Center(
          child: Column(
            children: [
              Container(
                width: isDesktop ? 120 : (isTablet ? 100 : 80),
                height: isDesktop ? 120 : (isTablet ? 100 : 80),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  borderRadius: BorderRadius.circular(
                      isDesktop ? 60 : (isTablet ? 50 : 40)),
                ),
                child: Icon(
                  Icons.store,
                  size: isDesktop ? 60 : (isTablet ? 50 : 40),
                  color: AppTheme.grey400,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'No Animals Available',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 24 : (isTablet ? 20 : 18),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.grey700,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No animals are currently listed for trading.\nCheck back later or add your own animals!',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 16 : (isTablet ? 14 : 12),
                  color: AppTheme.grey500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/animals/add'),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Animal',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        return Icons.agriculture;
      case 'GOAT':
        return Icons.pets;
      case 'SHEEP':
        return Icons.eco;
      default:
        return Icons.pets;
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
