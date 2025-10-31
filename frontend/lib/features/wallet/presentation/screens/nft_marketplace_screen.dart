import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../trading/data/models/trade_models.dart';
import '../../../trading/providers/trading_provider.dart';
import '../../../trading/data/repositories/trading_repository.dart';
import '../../../trading/presentation/widgets/trade_confirmation_dialog.dart';
import '../../../animals/data/models/animal_models.dart';
import '../../../animals/providers/animals_provider.dart';
import '../../../shared/presentation/widgets/custom_button.dart';
import '../widgets/nft_detail_modal.dart';
import '../widgets/list_nft_dialog.dart';

class NftMarketplaceScreen extends ConsumerStatefulWidget {
  const NftMarketplaceScreen({super.key});

  @override
  ConsumerState<NftMarketplaceScreen> createState() =>
      _NftMarketplaceScreenState();
}

class _NftMarketplaceScreenState extends ConsumerState<NftMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceProvider.notifier).getAvailableTrades();
      ref.read(myAnimalsProvider.notifier).getMyAnimals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'NFT Marketplace',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.getMutedTextColor(context),
          labelStyle: GoogleFonts.poppins(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Browse NFTs'),
            Tab(text: 'My NFTs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketplace(isTablet),
          _buildMyNFTs(isTablet),
        ],
      ),
    );
  }

  Widget _buildMarketplace(bool isTablet) {
    final marketplaceState = ref.watch(marketplaceProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(marketplaceProvider.notifier).refresh();
      },
      color: AppTheme.primaryColor,
      child: marketplaceState.when(
        data: (trades) {
          // Apply simple client-side search/filter
          final filtered = trades.where((t) {
            if (_activeFilter != 'All' &&
                (t.status).toUpperCase() != _activeFilter.toUpperCase()) {
              return false;
            }
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            final name = (t.animal?.name ?? '').toLowerCase();
            final species = (t.animal?.species ?? '').toLowerCase();
            final breed = (t.animal?.breed ?? '').toLowerCase();
            return name.contains(q) || species.contains(q) || breed.contains(q);
          }).toList();

          if (filtered.isEmpty) {
            return _buildEmptyState(
              'No NFTs Listed',
              'Check back later for available NFTs',
              isTablet,
            );
          }
          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = width >= 1024 ? 4 : (isTablet ? 3 : 2);
          final spacing = width >= 1024 ? 18.0 : (isTablet ? 16.0 : 12.0);

          return Column(
            children: [
              _buildMarketplaceHeader(isTablet),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 24 : 16,
                    0,
                    isTablet ? 24 : 16,
                    isTablet ? 24 : 16,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final trade = filtered[index];
                    return _buildNFTCard(trade, isTablet, forSale: true);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => _buildLoadingGrid(isTablet),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
              SizedBox(height: 16),
              Text(
                'Error loading marketplace',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(marketplaceProvider.notifier).refresh(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyNFTs(bool isTablet) {
    final myAnimalsState = ref.watch(myAnimalsProvider);

    return myAnimalsState.when(
      data: (animals) {
        // Filter for minted NFTs (has tokenId)
        final mintedNFTs = animals
            .where((animal) =>
                animal.tokenId != null && animal.tokenId!.isNotEmpty)
            .toList();

        if (mintedNFTs.isEmpty) {
          return _buildEmptyState(
            'No NFTs Yet',
            'Purchase or mint your first NFT to get started',
            isTablet,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(myAnimalsProvider.notifier).refresh();
          },
          color: AppTheme.primaryColor,
          child: GridView.builder(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: isTablet ? 16 : 12,
              mainAxisSpacing: isTablet ? 16 : 12,
            ),
            itemCount: mintedNFTs.length,
            itemBuilder: (context, index) {
              final nft = mintedNFTs[index];
              return _buildOwnedNFTCard(nft, isTablet);
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            SizedBox(height: 16),
            Text(
              'Error loading your NFTs',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(myAnimalsProvider.notifier).refresh(),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNFTCard(Trade trade, bool isTablet, {bool forSale = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return InkWell(
      onTap: () => _showNFTDetails(trade),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: trade.animal?.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppTheme.grey100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.grey100,
                        child: Icon(
                          Icons.image_not_supported,
                          size: isTablet ? 48 : 40,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trade.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        (trade.status).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NFT Info
            Padding(
              padding: EdgeInsets.all(isTablet ? 14 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trade.animal?.name ?? 'Unnamed',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 8 : 6),
                  Row(
                    children: [
                      Icon(
                        Icons.pets_rounded,
                        size: isTablet ? 14 : 12,
                        color: AppTheme.getMutedTextColor(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${trade.animal?.species ?? 'Unknown'} • ${trade.animal?.breed ?? 'Mixed'}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 12 : 11,
                            color: AppTheme.getMutedTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${trade.price} ${trade.currency}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (forSale)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getPrimaryColor(context)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.shopping_cart_rounded,
                            size: isTablet ? 18 : 16,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnedNFTCard(Animal nft, bool isTablet) {
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return InkWell(
      onTap: () => _showOwnedNFTOptions(nft),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: nft.imageUrl ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppTheme.grey100,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.grey100,
                        child: Icon(
                          Icons.image_not_supported,
                          size: isTablet ? 48 : 40,
                          color: AppTheme.getMutedTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  if (nft.isListed == true)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Listed',
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
            ),

            // NFT Info
            Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.name,
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 4 : 2),
                  Text(
                    'Token #${nft.tokenSerialNumber ?? 'N/A'}',
                    style: GoogleFonts.robotoMono(
                      fontSize: isTablet ? 12 : 11,
                      color: AppTheme.getMutedTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.getPrimaryColor(context).withOpacity(0.12),
                  AppTheme.getPrimaryColor(context).withOpacity(0.06),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.collections_bookmark_rounded,
              size: isTablet ? 72 : 60,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : 13,
              color: AppTheme.getMutedTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showNFTDetails(Trade trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NftDetailModal(
        trade: trade,
        onPurchase: () async {
          Navigator.pop(context); // Close detail modal first
          // Show purchase confirmation dialog
          final success = await showDialog<bool>(
            context: context,
            builder: (context) => TradeConfirmationDialog(trade: trade),
          );
          
          if (success == true && mounted) {
            // Refresh marketplace and owned NFTs after purchase
            ref.read(marketplaceProvider.notifier).refresh();
            ref.read(myAnimalsProvider.notifier).getMyAnimals();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Purchase completed successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
      ),
    );
  }

  void _showOwnedNFTOptions(Animal nft) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.grey900 : AppTheme.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nft.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 24),
            if (nft.isListed != true)
              CustomButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showListNFTDialog(nft);
                },
                text: 'List for Sale',
              ),
            if (nft.isListed == true) ...[
              CustomButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _cancelListing(nft);
                },
                text: 'Cancel Listing',
                backgroundColor: AppTheme.errorColor,
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getMutedTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelListing(Animal nft) async {
    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Listing'),
        content: Text(
            'Are you sure you want to cancel the listing for ${nft.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    // Get user's trades to find the active listing for this animal
    try {
      final myTrades = await ref.read(tradingRepositoryProvider).getMyTrades();
      final activeTrade = myTrades.firstWhere(
        (trade) =>
            trade.animalId == nft.id &&
            (trade.status == 'LISTED' || trade.status == 'PENDING'),
        orElse: () => throw Exception('No active listing found'),
      );

      // Cancel the trade
      await ref.read(tradingRepositoryProvider).cancelTrade(activeTrade.id);

      // Show success message and refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Listing cancelled successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        // Refresh data
        ref.read(myAnimalsProvider.notifier).refresh();
        ref.read(marketplaceProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel listing: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showListNFTDialog(Animal nft) {
    showDialog(
      context: context,
      builder: (context) => ListNftDialog(
        nft: nft,
        onListed: () {
          // Refresh the NFT list and marketplace
          ref.read(myAnimalsProvider.notifier).refresh();
          ref.read(marketplaceProvider.notifier).refresh();
        },
      ),
    );
  }
}

// UI helpers
extension on _NftMarketplaceScreenState {
  Color _getStatusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'listed':
        return const Color(0xFF10B981);
      case 'sold':
        return const Color(0xFF64748B);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildMarketplaceHeader(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(isTablet ? 24 : 16, isTablet ? 20 : 16,
          isTablet ? 24 : 16, isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
              color: AppTheme.getBorderColorFromContext(context), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) =>
                      this.setState(() => _searchQuery = v.trim()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'Search NFTs, species, breed... ',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: AppTheme.getBorderColorFromContext(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                          color: AppTheme.getBorderColorFromContext(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          BorderSide(color: AppTheme.getPrimaryColor(context)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              IconButton(
                onPressed: () {
                  _showFiltersSheet();
                },
                icon: const Icon(Icons.tune_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final label in ['All', 'Listed', 'Sold', 'Pending'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _activeFilter == label,
                      onSelected: (_) =>
                          this.setState(() => _activeFilter = label),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(bool isTablet) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1024 ? 4 : (isTablet ? 3 : 2);
    final spacing = width >= 1024 ? 18.0 : (isTablet ? 16.0 : 12.0);

    return Column(
      children: [
        _buildMarketplaceHeader(isTablet),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24 : 16,
              0,
              isTablet ? 24 : 16,
              isTablet ? 24 : 16,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: crossAxisCount * 4,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.getCardBackground(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.getBorderColorFromContext(context)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                        ),
                      ),
                    ),
                    Container(
                      height: 72,
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in ['All', 'Listed', 'Sold', 'Pending'])
                      ChoiceChip(
                        label: Text(label),
                        selected: _activeFilter == label,
                        onSelected: (_) {
                          this.setState(() => _activeFilter = label);
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
