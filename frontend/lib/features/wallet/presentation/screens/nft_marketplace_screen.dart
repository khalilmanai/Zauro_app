import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../trading/data/models/trade_models.dart';
import '../../../trading/providers/trading_provider.dart';
import '../../../trading/data/repositories/trading_repository.dart';
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
          if (trades.isEmpty) {
            return _buildEmptyState(
              'No NFTs Listed',
              'Check back later for available NFTs',
              isTablet,
            );
          }
          return GridView.builder(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: isTablet ? 16 : 12,
              mainAxisSpacing: isTablet ? 16 : 12,
            ),
            itemCount: trades.length,
            itemBuilder: (context, index) {
              final trade = trades[index];
              return _buildNFTCard(trade, isTablet, forSale: true);
            },
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
    final cardColor = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColorFromContext(context);

    return InkWell(
      onTap: () => _showNFTDetails(trade),
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
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
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
            ),

            // NFT Info
            Padding(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trade.animal?.name ?? 'Unnamed',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${trade.price} ${trade.currency}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (forSale)
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: isTablet ? 18 : 16,
                          color: AppTheme.success,
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
          Icon(
            Icons.collections_outlined,
            size: isTablet ? 80 : 64,
            color: AppTheme.getMutedTextColor(context).withOpacity(0.3),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getMutedTextColor(context),
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : 13,
              color: AppTheme.getMutedTextColor(context).withOpacity(0.7),
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
          // TODO: Implement purchase logic
          Navigator.pop(context);
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
