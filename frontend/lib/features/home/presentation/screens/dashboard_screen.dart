import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/enhanced_loader.dart' as Enhanced;
import '../../../auth/providers/auth_provider.dart';
import '../../../wallet/data/models/wallet_models.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../trading/providers/trading_provider.dart';
import '../../../trading/data/models/trade_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final walletBalanceState = ref.watch(walletBalanceProvider);
    final marketplaceState = ref.watch(marketplaceProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(walletBalanceProvider.notifier).refresh(),
            ref.read(marketplaceProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            _buildModernHeader(context, ref, user),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive(
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 32.0,
                ),
                vertical: context.responsive(
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildStatsOverview(context, ref, walletBalanceState),
                  const SizedBox(height: 32),
                  _buildMarketplaceSection(context, ref, marketplaceState),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, WidgetRef ref, dynamic user) {
    final isMobile = context.isMobile;
    final userName = user?.fullName ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: isMobile ? 140 : 100,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Clean Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.getPrimaryColor(context)
                                .withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.getPrimaryColor(context)
                              .withOpacity(0.1),
                          backgroundImage: user?.avatarUrl != null &&
                                  user?.avatarUrl?.isNotEmpty == true
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null ||
                                  user?.avatarUrl?.isEmpty == true
                              ? Text(
                                  user?.firstName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.getPrimaryColor(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppTheme.grey400
                                    : AppTheme.grey600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppTheme.grey900,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Theme toggle
                      _buildThemeToggle(context, ref),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final isDark = themeState == AppThemeMode.dark;

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        onTap: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : AppTheme.withOpacity(AppTheme.black, 0.05),
              width: 1,
            ),
          ),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            size: 20,
            color: isDark ? AppTheme.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'List Animal',
        'route': '/animals/add',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'route': '/wallet',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.store_outlined,
        'label': 'Marketplace',
        'route': '/marketplace',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.pets_outlined,
        'label': 'My Animals',
        'route': '/animals',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: actions.map((action) {
        return _buildSimpleActionCard(
          context,
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: action['color'] as Color,
          onTap: () => context.push(action['route'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildSimpleActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.grey900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, WidgetRef ref,
      AsyncValue<WalletBalance?> walletBalanceState) {
    return walletBalanceState.when(
      data: (balance) => _buildStatsCards(context, balance),
      loading: () => _buildStatsLoading(context),
      error: (error, stackTrace) => _buildStatsError(context, error),
    );
  }

  Widget _buildStatsCards(BuildContext context, WalletBalance? balance) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildSimpleStatsCard(
          context: context,
          icon: Icons.account_balance_wallet_outlined,
          title: 'HBAR',
          value: balance?.displayHbar ?? '0.00',
          color: const Color(0xFF3B82F6),
          onTap: () => context.push('/wallet'),
        ),
        _buildSimpleStatsCard(
          context: context,
          icon: Icons.token_outlined,
          title: 'ZAU',
          value: balance?.displayZau ?? '0.00',
          color: const Color(0xFF10B981),
          onTap: () => context.push('/wallet'),
        ),
      ],
    );
  }

  Widget _buildSimpleStatsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.grey900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsLoading(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: List.generate(2, (index) {
        return Enhanced.ShimmerCard(
          height: 120,
          borderRadius: 16,
        );
      }),
    );
  }

  Widget _buildStatsError(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Log error for debugging
    print('Wallet Balance Error: $error');
    print('Error type: ${error.runtimeType}');
    print(
        'Error details: ${error.toString().isEmpty ? "EMPTY ERROR" : error.toString()}');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.red.shade900.withOpacity(0.2)
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Failed to load wallet data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onErrorContainer
                            .withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(walletBalanceProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceSection(BuildContext context, WidgetRef ref,
      AsyncValue<List<Trade>> marketplaceState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Marketplace',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.grey900,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/marketplace');
                HapticFeedback.lightImpact();
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPrimaryColor(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        marketplaceState.when(
          data: (trades) => _buildMarketplaceGrid(context, trades),
          loading: () => _buildMarketplaceLoading(),
          error: (error, stackTrace) => _buildMarketplaceError(context),
        ),
      ],
    );
  }

  Widget _buildMarketplaceGrid(BuildContext context, List<Trade> trades) {
    if (trades.isEmpty) {
      return _buildEmptyMarketplace(context);
    }

    final isDesktop = context.isDesktop;
    final crossAxisCount = isDesktop ? 4 : 2;
    final childAspectRatio = isDesktop ? 0.72 : 0.75;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: trades.length > 8 ? 8 : trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildAnimalCard(context, trade, index);
      },
    );
  }

  Widget _buildAnimalCard(BuildContext context, Trade trade, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to trade details
        HapticFeedback.lightImpact();
      },
      child: Container(
        decoration: AppTheme.getPremiumCardDecoration(
          context: context,
          isDark: isDark,
          borderRadius: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Animal Image with overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF1F5F9),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: trade.animal?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                            child: Image.network(
                              trade.animal!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderImage(isDark),
                            ),
                          )
                        : _buildPlaceholderImage(isDark),
                  ),
                  // Enhanced gradient overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // Status badge with enhanced styling
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(trade.status).withOpacity(0.9),
                            _getStatusColor(trade.status).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getStatusColor(trade.status).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(trade.status),
                            size: 12,
                            color: AppTheme.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trade.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: AppTheme.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced Animal Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trade.animal?.name ?? 'Unknown Animal',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color:
                                  isDark ? AppTheme.white : AppTheme.slate800,
                              letterSpacing: -0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.getPrimaryColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pets_rounded,
                            size: 12,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${trade.animal?.species ?? 'Unknown'} • ${trade.animal?.breed ?? 'Mixed'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getPrimaryColor(context),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Enhanced price section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient:
                            AppTheme.getNeonPrimaryGradient(isDark: isDark),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.getPrimaryNeonGlow(isDark: isDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${trade.price} ${trade.currency}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Starting price',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      AppTheme.withOpacity(AppTheme.white, 0.8),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'listed':
        return Icons.inventory_2_rounded;
      case 'sold':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE2E8F0),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 48,
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildEmptyMarketplace(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFFA855F7).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 64,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No active trades',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to list an animal!',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/animals/add'),
            icon: const Icon(Icons.add),
            label: Text(
              'List Your First Animal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildMarketplaceLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: context.isDesktop ? 0.72 : 0.75,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Enhanced.ShimmerCard(
          height: 300,
          borderRadius: 20,
        )
            .animate(delay: Duration(milliseconds: index * 100))
            .fadeIn(duration: const Duration(milliseconds: 400));
      },
    );
  }

  Widget _buildMarketplaceError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color:
            isDark ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'Failed to load marketplace',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please check your connection and try again',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(marketplaceProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              'Retry',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
}
