import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/responsive_button_row.dart';
import '../../../../core/widgets/neon_glow_widget.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/premium_button.dart';
import '../../../../core/widgets/enhanced_loader.dart' as Enhanced;
import '../../../auth/providers/auth_provider.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../../wallet/data/models/wallet_models.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../animals/providers/animals_provider.dart';
import '../../../trading/providers/trading_provider.dart';
import '../../../trading/data/models/trade_models.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Dogs',
    'Cats',
    'Birds',
    'Fish',
    'Other'
  ];
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
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final walletState = ref.watch(walletProvider);
    final walletBalanceState = ref.watch(walletBalanceProvider);
    final marketplaceState = ref.watch(marketplaceProvider);
    final isDesktop = context.isDesktop;
    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: authState.isLoading ||
            walletState.isLoading ||
            marketplaceState.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(walletProvider.notifier).refresh(),
              ref.read(walletBalanceProvider.notifier).refresh(),
              ref.read(myAnimalsProvider.notifier).refresh(),
              ref.read(marketplaceProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              _buildEnhancedHeader(context, ref, user),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: 16.0,
                    tablet: 24.0,
                    desktop: 32.0,
                  ),
                  vertical: context.responsive(
                    mobile: 20.0,
                    tablet: 24.0,
                    desktop: 32.0,
                  ),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isDesktop) _buildWelcomeSection(context, user),
                    if (isDesktop)
                      SizedBox(
                          height:
                              context.responsive(mobile: 24.0, desktop: 32.0)),
                    _buildQuickActions(context),
                    SizedBox(
                        height:
                            context.responsive(mobile: 24.0, desktop: 32.0)),
                    _buildStatsOverview(context, ref, walletBalanceState),
                    SizedBox(
                        height:
                            context.responsive(mobile: 32.0, desktop: 40.0)),
                    _buildSearchAndFilter(context),
                    const SizedBox(height: 24),
                    _buildMarketplaceSection(context, ref, marketplaceState),
                    SizedBox(
                        height:
                            context.responsive(mobile: 60.0, desktop: 40.0)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(
      BuildContext context, WidgetRef ref, dynamic user) {
    final isDesktop = context.isDesktop;
    final isMobile = context.isMobile;
    final userName = user?.fullName ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: isMobile ? 140 : 0,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.getCardBackground(context),
      elevation: 0,
      shadowColor: isDark
          ? AppTheme.transparent
          : AppTheme.withOpacity(AppTheme.black, 0.12),
      surfaceTintColor: AppTheme.transparent,
      title: isDesktop ? _buildDesktopHeaderTitle(context, userName) : null,
      actions: isDesktop
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderAction(
                      context,
                      icon: Icons.notifications_outlined,
                      badge: 3,
                      onTap: () {
                        // Handle notifications
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildHeaderAction(
                      context,
                      icon: Icons.settings_outlined,
                      onTap: () {
                        // Handle settings
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildThemeToggle(context, ref),
                  ],
                ),
              ),
            ]
          : null,
      flexibleSpace: isMobile
          ? FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppTheme.getBrandGradientColors(),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // Enhanced Avatar with glow
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.withOpacity(
                                        AppTheme.white, 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    AppTheme.withOpacity(AppTheme.white, 0.25),
                                backgroundImage: user?.avatarUrl != null
                                    ? NetworkImage(user!.avatarUrl!)
                                    : null,
                                child: user?.avatarUrl == null
                                    ? Text(
                                        user?.firstName
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            'U',
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // User info with better typography
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.withOpacity(
                                          AppTheme.white, 0.85),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.white,
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
            )
          : null,
    );
  }

  Widget _buildDesktopHeaderTitle(BuildContext context, String userName) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderAction(
    BuildContext context, {
    required IconData icon,
    int? badge,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: AppTheme.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.withOpacity(AppTheme.white, 0.1)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppTheme.withOpacity(AppTheme.white, 0.1)
                      : AppTheme.withOpacity(AppTheme.black, 0.05),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.red500,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.withOpacity(AppTheme.red500, 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    badge > 99 ? '99+' : badge.toString(),
                    style: GoogleFonts.poppins(
                      color: AppTheme.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
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

  Widget _buildWelcomeSection(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final userName = user?.fullName ?? 'User';
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFA855F7),
                ]
              : [
                  const Color(0xFF8B5CF6),
                  const Color(0xFFA855F7),
                  const Color(0xFFEC4899),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.withOpacity(AppTheme.white, 0.85),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ready to explore the Zauro Marketplace?',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.withOpacity(AppTheme.white, 0.9),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.withOpacity(AppTheme.white, 0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.withOpacity(AppTheme.white, 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.pets,
              color: AppTheme.white,
              size: 48,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;

    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'label': 'List Animal',
        'route': '/animals/add'
      },
      {'icon': Icons.wallet, 'label': 'Wallet', 'route': '/wallet'},
      {'icon': Icons.store, 'label': 'Marketplace', 'route': '/marketplace'},
      {'icon': Icons.pets, 'label': 'My Animals', 'route': '/animals'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Padding(
            padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
            child: _buildQuickActionButton(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: () => context.push(action['route'] as String),
              delay: index * 100,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.getThemeAwareColor(context,
              lightColor: AppTheme.white, darkColor: AppTheme.slate800),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppTheme.withOpacity(AppTheme.white, 0.1)
                : AppTheme.withOpacity(AppTheme.black, 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : AppTheme.withOpacity(AppTheme.black, 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6),
                    const Color(0xFFA855F7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.white : AppTheme.slate800,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(begin: 0.1, end: 0);
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
    final isDesktop = context.isDesktop;
    final isMobile = context.isMobile;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildEnhancedStatsCard(
          context: context,
          icon: Icons.account_balance_wallet,
          title: 'HBAR Balance',
          value: balance?.hbar ?? '0.00',
          subtitle: 'Hedera Hashgraph',
          color: AppTheme.blue500,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.blue500, AppTheme.blue600],
          ),
          onTap: () => context.push('/wallet'),
          delay: 0,
        ),
        _buildEnhancedStatsCard(
          context: context,
          icon: Icons.token,
          title: 'ZAU Balance',
          value: balance?.zau ?? '0.00',
          subtitle: 'Zauro Token',
          color: AppTheme.green500,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.green500, AppTheme.teal500],
          ),
          onTap: () => context.push('/wallet'),
          delay: 100,
        ),
        _buildEnhancedStatsCard(
          context: context,
          icon: Icons.pets,
          title: 'Animals',
          value: '0',
          subtitle: 'My Collections',
          color: AppTheme.orange500,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.orange500, AppTheme.pink500],
          ),
          onTap: () => context.push('/animals'),
          delay: 200,
        ),
        _buildEnhancedStatsCard(
          context: context,
          icon: Icons.store,
          title: 'Active Trades',
          value: '0',
          subtitle: 'Marketplace Activity',
          color: AppTheme.purple500,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.purple500, AppTheme.violet500],
          ),
          onTap: () => context.push('/marketplace'),
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildEnhancedStatsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    final isDesktop = context.isDesktop;
    return Flexible(
      child: SizedBox(
        width: isDesktop ? 220 : double.infinity,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 16,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.withOpacity(AppTheme.white, 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.withOpacity(AppTheme.white, 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: AppTheme.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppTheme.withOpacity(AppTheme.white, 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: AppTheme.white,
                    fontSize: isDesktop ? 30 : 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppTheme.withOpacity(AppTheme.white, 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.1, end: 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildStatsLoading(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(4, (index) {
        return Flexible(
          child: SizedBox(
            width: isDesktop ? 220 : double.infinity,
            child: Enhanced.ShimmerCard(
              height: isDesktop ? 180 : 160,
              borderRadius: 20,
            )
                .animate(delay: Duration(milliseconds: index * 100))
                .fadeIn(duration: const Duration(milliseconds: 400))
                .slideY(begin: 0.1, end: 0),
          ),
        );
      }),
    );
  }

  Widget _buildStatsError(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load wallet data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.withOpacity(AppTheme.black, 0.3)
                : AppTheme.withOpacity(AppTheme.black, 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.explore,
                color: isDark ? AppTheme.white : AppTheme.slate800,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Discover Animals',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.white : AppTheme.slate800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Enhanced Search Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : AppTheme.slate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? AppTheme.white : AppTheme.slate800,
              ),
              decoration: InputDecoration(
                hintText: 'Search animals, breeds, or sellers...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : Colors.black.withOpacity(0.4),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.6),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Enhanced Filter Chips
          Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : Colors.black.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.asMap().entries.map((entry) {
                final index = entry.key;
                final filter = entry.value;
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildFilterChip(filter, isSelected, isDark)
                      .animate(
                          delay: Duration(milliseconds: 400 + (index * 50)))
                      .fadeIn(duration: const Duration(milliseconds: 300))
                      .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6),
                    const Color(0xFFA855F7),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppTheme.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.withOpacity(AppTheme.purple500, 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppTheme.white
                : isDark
                    ? AppTheme.withOpacity(AppTheme.white, 0.7)
                    : AppTheme.slate500,
          ),
        ),
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
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: isDark ? AppTheme.white : AppTheme.slate800,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Marketplace',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.white : AppTheme.slate800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push('/marketplace'),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
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
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getThemeAwareColor(context,
              lightColor: AppTheme.white, darkColor: AppTheme.slate800),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppTheme.withOpacity(AppTheme.white, 0.1)
                : AppTheme.withOpacity(AppTheme.black, 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
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
                        top: Radius.circular(20),
                      ),
                    ),
                    child: trade.animal?.imageUrl != null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
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
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
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
                        color: _getStatusColor(trade.status).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getStatusColor(trade.status).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        trade.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                          letterSpacing: 0.5,
                        ),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.animal?.name ?? 'Unknown Animal',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.white : AppTheme.slate800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 14,
                          color: isDark
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${trade.animal?.species ?? 'Unknown'} • ${trade.animal?.breed ?? 'Mixed'}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.black.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                            const Color(0xFFA855F7).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.withOpacity(AppTheme.purple500, 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${trade.price} ${trade.currency}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B5CF6),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: const Color(0xFF8B5CF6),
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
        .fadeIn(duration: const Duration(milliseconds: 500))
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
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
