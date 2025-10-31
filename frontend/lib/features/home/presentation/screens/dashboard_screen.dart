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
import '../widgets/dashboard_search_modal.dart';
import '../widgets/dashboard_filter_modal.dart';

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
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                  mobile: 12.0,
                  tablet: 24.0,
                  desktop: 32.0,
                  largeDesktop: 48.0,
                ),
                vertical: context.responsive(
                  mobile: 12.0,
                  tablet: 20.0,
                  desktop: 24.0,
                  largeDesktop: 32.0,
                ),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildWalletBalanceSection(context, ref, walletBalanceState),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 28),
                  _buildRecentActivitySection(context),
                  const SizedBox(height: 28),
                  _buildMarketplaceSection(context, ref, marketplaceState),
                  const SizedBox(height: 120),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, WidgetRef ref, dynamic user) {
    final userName = user?.fullName ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // IMPORTANT: Return a Sliver directly; do not wrap the SliverAppBar with
    // animation widgets that convert it into a RenderBox.
    return SliverAppBar(
      expandedHeight: context.responsive(
        mobile: 180.0,
        tablet: 160.0,
        desktop: 140.0,
      ),
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? const Color(0xFF0F172A) : Colors.white,
                AppTheme.getPrimaryColor(context)
                    .withOpacity(isDark ? 0.15 : 0.10),
                AppTheme.getPrimaryColor(context)
                    .withOpacity(isDark ? 0.08 : 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      // Enhanced Avatar with glow and pulse animation
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.getPrimaryColor(context),
                              AppTheme.getPrimaryColor(context)
                                  .withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getPrimaryColor(context)
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: context.responsive(
                            mobile: 24.0,
                            tablet: 28.0,
                            desktop: 32.0,
                            largeDesktop: 36.0,
                          ),
                          backgroundColor:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
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
                                    fontSize: context.responsive(
                                      mobile: 18.0,
                                      tablet: 20.0,
                                      desktop: 22.0,
                                      largeDesktop: 26.0,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.1)),
                      const SizedBox(width: 18),
                      // User info with enhanced greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getTimeBasedGreeting(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.grey300
                                        : AppTheme.grey700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _getGreetingIcon(),
                                  size: 18,
                                  color: const Color(0xFFFBBF24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userName,
                              style: GoogleFonts.poppins(
                                fontSize: context.responsive(
                                  mobile: 20.0,
                                  tablet: 22.0,
                                  desktop: 24.0,
                                  largeDesktop: 28.0,
                                ),
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.grey900,
                                letterSpacing: -0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ready to explore the marketplace?',
                              style: GoogleFonts.poppins(
                                fontSize: context.responsive(
                                  mobile: 11.0,
                                  tablet: 12.0,
                                  desktop: 13.0,
                                  largeDesktop: 14.0,
                                ),
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? AppTheme.grey400
                                    : AppTheme.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Enhanced theme toggle with notification bell
                      Row(
                        children: [
                          _buildNotificationBell(context),
                          const SizedBox(width: 12),
                          _buildThemeToggle(context, ref),
                        ],
                      ),
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
          HapticFeedback.mediumImpact();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                  )
                : null,
            color: isDark ? null : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: isDark ? AppTheme.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletBalanceSection(BuildContext context, WidgetRef ref,
      AsyncValue<WalletBalance?> walletBalanceState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Text(
                'Wallet Balance',
                style: GoogleFonts.poppins(
                  fontSize: context.responsive(
                    mobile: 16.0,
                    tablet: 17.0,
                    desktop: 18.0,
                    largeDesktop: 20.0,
                  ),
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.grey900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.getNeonPrimaryGradient(isDark: isDark),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Live',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        walletBalanceState.when(
          data: (balance) => _buildWalletCards(context, balance),
          loading: () => _buildWalletLoading(context),
          error: (error, stackTrace) => _buildWalletError(context, error),
        ),
      ],
    );
  }

  Widget _buildWalletCards(BuildContext context, WalletBalance? balance) {
    return Row(
      children: [
        Expanded(
          child: _buildBalanceCard(
            context: context,
            title: 'HBAR',
            value: balance?.displayHbar ?? '0.00',
            icon: Icons.account_balance_wallet_rounded,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF3B82F6),
                const Color(0xFF2563EB),
              ],
            ),
            onTap: () => context.push('/wallet'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBalanceCard(
            context: context,
            title: 'ZAU',
            value: balance?.displayZau ?? '0.00',
            icon: Icons.toll_rounded,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
            onTap: () => context.push('/wallet'),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildBalanceCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Row(
                  children: [
                    // Animated balance indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2))
                        .fadeIn(duration: 1000.ms),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Animated balance value
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: context.responsive(
                  mobile: 24.0,
                  tablet: 26.0,
                  desktop: 28.0,
                  largeDesktop: 32.0,
                ),
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            // Balance change indicator (mock data)
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '+2.5% today',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletLoading(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.1)),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.1)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.1)),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .shimmer(
                              duration: 1500.ms,
                              color: Colors.white.withOpacity(0.1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .shimmer(
                          duration: 1500.ms,
                          color: Colors.white.withOpacity(0.1)),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildWalletError(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load wallet balance',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.grey900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(walletBalanceProvider.notifier).refresh();
                HapticFeedback.mediumImpact();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_rounded,
        'label': 'List Animal',
        'route': '/animals/add',
        'gradient': LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        'description': 'Add new livestock',
      },
      {
        'icon': Icons.storefront_rounded,
        'label': 'Marketplace',
        'route': '/marketplace',
        'gradient': LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        'description': 'Browse listings',
      },
      {
        'icon': Icons.pets_rounded,
        'label': 'My Animals',
        'route': '/animals',
        'gradient': LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        'description': 'Manage portfolio',
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Analytics',
        'route': '/analytics',
        'gradient': LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        ),
        'description': 'View insights',
      },
    ];

    final crossAxisCount = context.responsive(
      mobile: 2,
      tablet: 4,
      desktop: 4,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: context.responsive(
                    mobile: 18.0,
                    tablet: 19.0,
                    desktop: 20.0,
                    largeDesktop: 22.0,
                  ),
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.grey900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.getPrimaryColor(context).withOpacity(0.2),
                      AppTheme.getPrimaryColor(context).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Most Used',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getPrimaryColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: context.responsive(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
            largeDesktop: 24.0,
          ),
          mainAxisSpacing: context.responsive(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
            largeDesktop: 24.0,
          ),
          childAspectRatio: context.responsive(
            mobile: 1.1,
            tablet: 1.15,
            desktop: 1.2,
            largeDesktop: 1.25,
          ),
          children: actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return _buildEnhancedActionCard(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              description: action['description'] as String,
              gradient: action['gradient'] as Gradient,
              onTap: () => context.push(action['route'] as String),
              index: index,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.grey900,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: MouseRegion(
        onEnter: (_) {
          // Add hover effect logic if needed
        },
        onExit: (_) {
          // Remove hover effect logic if needed
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: context.responsive(
                      mobile: 13.0,
                      tablet: 14.0,
                      desktop: 15.0,
                      largeDesktop: 16.0,
                    ),
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.grey900,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: context.responsive(
                      mobile: 10.0,
                      tablet: 10.5,
                      desktop: 11.0,
                      largeDesktop: 12.0,
                    ),
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.15, end: 0)
        .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1));
  }

  Widget _buildMarketplaceSection(BuildContext context, WidgetRef ref,
      AsyncValue<List<Trade>> marketplaceState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Featured Listings',
                    style: GoogleFonts.poppins(
                      fontSize: context.responsive(
                        mobile: 18.0,
                        tablet: 19.0,
                        desktop: 20.0,
                        largeDesktop: 22.0,
                      ),
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.grey900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFBBF24).withOpacity(0.2),
                          const Color(0xFFFBBF24).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 14,
                          color: const Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Trending',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFBBF24),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Responsive button layout with flexible sizing
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: context.isMobile
                      ? IconButton(
                          onPressed: () {
                            context.push('/marketplace');
                            HapticFeedback.lightImpact();
                          },
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context)
                                .withOpacity(0.1),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Search button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const DashboardSearchModal(),
                                  );
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: isDark
                                      ? AppTheme.grey400
                                      : AppTheme.grey600,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Filter button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const DashboardFilterModal(),
                                  );
                                  HapticFeedback.lightImpact();
                                },
                                icon: Icon(
                                  Icons.filter_list_rounded,
                                  size: 20,
                                  color: isDark
                                      ? AppTheme.grey400
                                      : AppTheme.grey600,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // View All button
                              TextButton(
                                onPressed: () {
                                  context.push('/marketplace');
                                  HapticFeedback.lightImpact();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  backgroundColor:
                                      AppTheme.getPrimaryColor(context)
                                          .withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppTheme.getPrimaryColor(context),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
    final childAspectRatio = isDesktop ? 0.7 : 0.72;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: context.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
          largeDesktop: 20.0,
        ),
        mainAxisSpacing: context.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
          largeDesktop: 20.0,
        ),
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
        context.push('/marketplace/trade/${trade.id}');
        HapticFeedback.lightImpact();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Animal Image
            Expanded(
              flex: 5,
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
                  // Gradient overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(trade.status),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getStatusColor(trade.status).withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        trade.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Animal Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                trade.animal?.name ?? 'Unknown Animal',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isDark ? Colors.white : AppTheme.grey900,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.getPrimaryColor(context)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppTheme.getPrimaryColor(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : AppTheme.grey100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : AppTheme.grey200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.pets_rounded,
                                size: 12,
                                color: isDark
                                    ? AppTheme.grey400
                                    : AppTheme.grey600,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  '${trade.animal?.species ?? 'Unknown'} • ${trade.animal?.breed ?? 'Mixed'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.grey400
                                        : AppTheme.grey600,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Price section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.getPrimaryColor(context),
                            AppTheme.getPrimaryColor(context).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryColor(context)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${trade.price} ${trade.currency}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Starting price',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.85),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
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
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
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
      ),
      child: Center(
        child: Icon(
          Icons.pets_rounded,
          size: 56,
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.15),
        ),
      ),
    );
  }

  Widget _buildEmptyMarketplace(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(56),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.15),
                  const Color(0xFFA855F7).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 72,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'No Listings Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.grey900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Be the first to list an animal\nand start trading today!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/animals/add');
              HapticFeedback.mediumImpact();
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              'List Your First Animal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: const Color(0xFF8B5CF6).withOpacity(0.5),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildMarketplaceLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isDesktop ? 4 : 2,
        crossAxisSpacing: context.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
          largeDesktop: 20.0,
        ),
        mainAxisSpacing: context.responsive(
          mobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
          largeDesktop: 20.0,
        ),
        childAspectRatio: context.responsive(
          mobile: 0.72,
          tablet: 0.7,
          desktop: 0.68,
          largeDesktop: 0.65,
        ),
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Enhanced.ShimmerCard(
          height: 320,
          borderRadius: 24,
        )
            .animate(delay: Duration(milliseconds: index * 80))
            .fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _buildMarketplaceError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: 56,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unable to Load Listings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.grey900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check your connection and try again',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? AppTheme.grey400 : AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(marketplaceProvider.notifier).refresh();
              HapticFeedback.mediumImpact();
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'Try Again',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      return Icons.wb_cloudy_rounded;
    } else {
      return Icons.nightlight_round;
    }
  }

  Widget _buildNotificationBell(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to notifications
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.08),
                    ],
                  )
                : null,
            color: isDark ? null : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: isDark ? AppTheme.white : theme.colorScheme.onSurface,
              ),
              // Notification badge (placeholder for now)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.push('/animals/add');
        HapticFeedback.mediumImpact();
      },
      backgroundColor: AppTheme.getPrimaryColor(context),
      foregroundColor: Colors.white,
      elevation: 8,
      heroTag: 'dashboard_fab', // Unique hero tag to fix duplicate hero error
      icon: const Icon(Icons.add_rounded, size: 24),
      label: Text(
        'List Animal',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .fadeIn(duration: 600.ms);
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock recent activities - in real app, this would come from a provider
    final activities = [
      {
        'icon': Icons.add_circle_rounded,
        'title': 'Listed Jersey Cow',
        'subtitle': '2 hours ago',
        'amount': '+150 ZAU',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.swap_horiz_rounded,
        'title': 'Traded with Farmer John',
        'subtitle': '5 hours ago',
        'amount': '+75 HBAR',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.pets_rounded,
        'title': 'Added Holstein Calf',
        'subtitle': '1 day ago',
        'amount': 'Portfolio',
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Row(
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: context.responsive(
                    mobile: 18.0,
                    tablet: 19.0,
                    desktop: 20.0,
                    largeDesktop: 22.0,
                  ),
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.grey900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.2),
                      Colors.green.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Live',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: activities.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              height: 24,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(
                context,
                icon: activity['icon'] as IconData,
                title: activity['title'] as String,
                subtitle: activity['subtitle'] as String,
                amount: activity['amount'] as String,
                color: activity['color'] as Color,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.grey900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppTheme.grey400 : AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    )
        .animate(delay: Duration(milliseconds: index * 150))
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }
}
