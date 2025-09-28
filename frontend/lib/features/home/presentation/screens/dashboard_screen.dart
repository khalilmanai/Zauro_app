import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/ai_enhanced_widgets.dart';
import '../../../../core/widgets/responsive_button_row.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../../wallet/providers/wallet_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final walletState = ref.watch(walletProvider);
    final isDesktop = context.isDesktop;
    final user = authState.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: authState.isLoading || walletState.isLoading,
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh wallet data
            await ref.read(walletProvider.notifier).refresh();
          },
          child: CustomScrollView(
            slivers: [
              _buildEnhancedHeader(context, ref, user),
              SliverPadding(
                padding: ResponsiveUtils.responsivePadding(context),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeSection(context, user),
                    SizedBox(
                        height:
                            context.responsive(mobile: 24.0, desktop: 32.0)),
                    _buildStatsOverview(context, ref, walletState),
                    SizedBox(
                        height:
                            context.responsive(mobile: 32.0, desktop: 40.0)),
                    if (isDesktop)
                      _buildDesktopLayout(context, ref)
                    else
                      _buildMobileLayout(context, ref),
                    SizedBox(
                        height:
                            context.responsive(mobile: 80.0, desktop: 40.0)),
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
    final userName = user?.fullName ?? 'User';
    final userEmail = user?.email ?? '';

    return SliverAppBar(
      expandedHeight: isDesktop ? 0 : 140,
      floating: false,
      pinned: !isDesktop,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: isDesktop ? _buildDesktopHeaderTitle(context, userName) : null,
      actions: isDesktop
          ? [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.refresh,
                      onTap: () => ref.read(walletProvider.notifier).refresh(),
                      tooltip: 'Refresh Data',
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderAction(
                      context: context,
                      icon: Icons.notifications_outlined,
                      onTap: () => _showNotifications(context),
                      badgeCount: 3,
                      tooltip: 'Notifications',
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderAction(
                      context: context,
                      icon: ref.watch(themeProvider).icon,
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                      tooltip: 'Toggle Theme',
                    ),
                    const SizedBox(width: 12),
                    _buildUserAvatar(context, userName, userEmail),
                  ],
                ),
              ),
            ]
          : null,
      flexibleSpace: isDesktop
          ? null
          : FlexibleSpaceBar(
              background:
                  _buildMobileHeaderBackground(context, userName, userEmail),
            ),
    );
  }

  Widget _buildDesktopHeaderTitle(BuildContext context, String userName) {
    return Row(
      children: [
        Icon(
          Icons.dashboard,
          color: AppTheme.getPrimaryColor(context),
          size: 28,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${_getGreeting()}, ${userName.split(' ').first}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar(
      BuildContext context, String userName, String userEmail) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.getPrimaryColor(context),
              AppTheme.getAccentColor(context),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline),
              const SizedBox(width: 12),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined),
              const SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red),
              const SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handleUserMenuAction(context, value),
    );
  }

  Widget _buildMobileHeaderBackground(
      BuildContext context, String userName, String userEmail) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getPrimaryColor(context),
            AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
            AppTheme.getAccentColor(context).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              _buildUserAvatar(context, userName, userEmail),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_getGreeting()}, ${userName.split(' ').first}!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back to your marketplace',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              _buildHeaderAction(
                context: context,
                icon: Icons.notifications_outlined,
                onTap: () => _showNotifications(context),
                badgeCount: 3,
                isLight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
    String? tooltip,
    bool isLight = false,
  }) {
    Widget button = Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.2)
                : AppTheme.getMutedColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppTheme.getBorderColor(context),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              size: 20,
              color: isLight
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    return tooltip != null
        ? Tooltip(
            message: tooltip,
            child: button,
          )
        : button;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _handleUserMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        context.go('/profile');
        break;
      case 'settings':
        // Navigate to settings
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Mark all read'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildNotificationItem(
                      context,
                      'New trade offer received',
                      'Someone is interested in your Golden Retriever NFT',
                      Icons.handshake,
                      Colors.blue,
                      '2 min ago',
                    ),
                    _buildNotificationItem(
                      context,
                      'Wallet funded successfully',
                      'Your wallet has been credited with 50 HBAR',
                      Icons.account_balance_wallet,
                      Colors.green,
                      '1 hour ago',
                    ),
                    _buildNotificationItem(
                      context,
                      'Market price alert',
                      'Cat NFTs are trending up by 15%',
                      Icons.trending_up,
                      Colors.orange,
                      '3 hours ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, dynamic user) {
    final userName = user?.fullName ?? 'User';

    if (context.isDesktop) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.getPrimaryColor(context),
              AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
              AppTheme.getAccentColor(context).withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
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
                    '${_getGreeting()}, ${userName.split(' ').first}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to your AI-powered animal marketplace dashboard. Manage your NFTs, track trades, and explore new opportunities with intelligent insights.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildWelcomeActionButton(
                        context,
                        'Get Started',
                        Icons.rocket_launch,
                        () => context.go('/animals/add'),
                      ),
                      const SizedBox(width: 12),
                      _buildWelcomeActionButton(
                        context,
                        'View Tutorial',
                        Icons.play_circle_outline,
                        () => _showTutorial(context),
                        isOutlined: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildWelcomeActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : Colors.white,
        foregroundColor:
            isOutlined ? Colors.white : AppTheme.getPrimaryColor(context),
        side:
            isOutlined ? const BorderSide(color: Colors.white, width: 1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    // Show tutorial modal or navigate to tutorial page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutorial'),
        content: const Text('Tutorial feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
      BuildContext context, WidgetRef ref, dynamic walletState) {
    final isDesktop = context.isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portfolio Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.getSuccessColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      AppTheme.getSuccessColor(context).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.getSuccessColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'All Systems Operational',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.getSuccessColor(context),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => context.go('/wallet'),
                  child: AIStatsCard(
                    title: 'Total Portfolio Value',
                    value: walletState.maybeWhen(
                      data: (wallet) => wallet?.balance?.hbar != null
                          ? '${wallet!.balance!.hbar} HBAR'
                          : '0.00 HBAR',
                      orElse: () => '0.00 HBAR',
                    ),
                    subtitle: '≈ \$0.00 USD',
                    icon: Icons.account_balance_wallet,
                    color: AppTheme.getPrimaryColor(context),
                    trend: '+0.00%',
                    isPositive: true,
                    isLarge: true,
                    hasAIGlow: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/animals'),
                      child: AIStatsCard(
                        title: 'My Animals',
                        value: '0',
                        subtitle: 'NFTs owned',
                        icon: Icons.pets,
                        color: AppTheme.getSuccessColor(context),
                        trend: '+0',
                        isPositive: true,
                        hasAIGlow: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.go('/marketplace'),
                      child: AIStatsCard(
                        title: 'Active Trades',
                        value: '0',
                        subtitle: 'In progress',
                        icon: Icons.trending_up,
                        color: AppTheme.getAccentColor(context),
                        trend: '+0',
                        isPositive: true,
                        hasAIGlow: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              GestureDetector(
                onTap: () => context.go('/wallet'),
                child: AIStatsCard(
                  title: 'Total Portfolio Value',
                  value: walletState.maybeWhen(
                    data: (wallet) => wallet?.balance?.hbar != null
                        ? '${wallet!.balance!.hbar} HBAR'
                        : '0.00 HBAR',
                    orElse: () => '0.00 HBAR',
                  ),
                  subtitle: '≈ \$0.00 USD',
                  icon: Icons.account_balance_wallet,
                  color: AppTheme.getPrimaryColor(context),
                  trend: '+0.00%',
                  isPositive: true,
                  isLarge: true,
                  hasAIGlow: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/animals'),
                      child: AIStatsCard(
                        title: 'My Animals',
                        value: '0',
                        subtitle: 'NFTs owned',
                        icon: Icons.pets,
                        color: AppTheme.getSuccessColor(context),
                        trend: '+0',
                        isPositive: true,
                        hasAIGlow: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/marketplace'),
                      child: AIStatsCard(
                        title: 'Active Trades',
                        value: '0',
                        subtitle: 'In progress',
                        icon: Icons.trending_up,
                        color: AppTheme.getAccentColor(context),
                        trend: '+0',
                        isPositive: true,
                        hasAIGlow: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildEnhancedQuickActions(context, ref),
              const SizedBox(height: 32),
              _buildEnhancedRecentActivity(context, ref),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: _buildEnhancedMarketInsights(context, ref),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildEnhancedQuickActions(context, ref),
        SizedBox(height: context.responsive(mobile: 24.0, desktop: 32.0)),
        _buildEnhancedRecentActivity(context, ref),
        SizedBox(height: context.responsive(mobile: 24.0, desktop: 32.0)),
        _buildEnhancedMarketInsights(context, ref),
      ],
    );
  }

  Widget _buildEnhancedQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.apps, size: 16),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount:
              ResponsiveUtils.getGridColumns(context, maxColumns: 4),
          crossAxisSpacing: context.responsive(mobile: 12.0, desktop: 16.0),
          mainAxisSpacing: context.responsive(mobile: 12.0, desktop: 16.0),
          childAspectRatio:
              context.responsive(mobile: 1.3, tablet: 1.2, desktop: 1.1),
          children: [
            AIActionCard(
              title: 'Add Animal',
              subtitle: 'Register new NFT',
              icon: Icons.add_circle_outline,
              color: AppTheme.getPrimaryColor(context),
              onTap: () => context.go('/animals/add'),
              hasAIGlow: true,
            ),
            AIActionCard(
              title: 'Browse Market',
              subtitle: 'Explore listings',
              icon: Icons.store_outlined,
              color: AppTheme.getSuccessColor(context),
              onTap: () => context.go('/marketplace'),
              hasAIGlow: false,
            ),
            AIActionCard(
              title: 'View Wallet',
              subtitle: 'Manage funds',
              icon: Icons.account_balance_wallet_outlined,
              color: AppTheme.getAccentColor(context),
              onTap: () => context.go('/wallet'),
              hasAIGlow: false,
            ),
            AIActionCard(
              title: 'AI Analytics',
              subtitle: 'Smart insights',
              icon: Icons.auto_awesome,
              color: Colors.purple,
              onTap: () => _showAnalytics(context),
              hasAIGlow: true,
            ),
          ],
        ),
      ],
    );
  }

  void _showAnalytics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Analytics',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Beta',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildAnalyticsCard(
                      context,
                      'Portfolio Performance',
                      'Your portfolio has grown by 12% this month',
                      Icons.trending_up,
                      Colors.green,
                      '↗️ +12%',
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      context,
                      'Market Prediction',
                      'Cat NFTs are expected to rise by 8% next week',
                      Icons.psychology,
                      Colors.blue,
                      '🔮 Prediction',
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      context,
                      'Optimal Trading Time',
                      'Best time to trade: Weekends 2-4 PM',
                      Icons.schedule,
                      Colors.orange,
                      '⏰ Timing',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String tag,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.getBorderColor(context),
        ),
        boxShadow: AppTheme.getContextShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRecentActivity(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.getPrimaryColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
            boxShadow: AppTheme.getContextShadow(context),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.getMutedColor(context),
                      AppTheme.getMutedColor(context).withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.timeline_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No recent activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start by adding your first animal or exploring the marketplace to see your activity here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              ResponsiveButtonRow(
                buttons: [
                  ResponsiveButtonData(
                    text: 'Add Animal',
                    icon: Icons.add,
                    onPressed: () => context.go('/animals/add'),
                    hasGlow: true,
                  ),
                  ResponsiveButtonData(
                    text: 'Browse Market',
                    icon: Icons.store,
                    onPressed: () => context.go('/marketplace'),
                    isOutlined: true,
                    hasGlow: false,
                  ),
                ],
                forceVerticalOnMobile: true,
                spacing: 12,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMarketInsights(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Market Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.getAccentColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Live',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.getAccentColor(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.getBorderColor(context),
              width: 1,
            ),
            boxShadow: AppTheme.getContextShadow(context),
          ),
          child: Column(
            children: [
              _buildEnhancedInsightItem(
                context: context,
                title: 'Active Listings',
                value: '1,234',
                change: '+12%',
                isPositive: true,
                icon: Icons.store,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              _buildEnhancedInsightItem(
                context: context,
                title: 'Average Price',
                value: '45.2 HBAR',
                change: '+5.8%',
                isPositive: true,
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              _buildEnhancedInsightItem(
                context: context,
                title: 'Total Volume',
                value: '12.5K HBAR',
                change: '+18.3%',
                isPositive: true,
                icon: Icons.bar_chart,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              _buildEnhancedInsightItem(
                context: context,
                title: 'Top Category',
                value: 'Livestock',
                change: '45% share',
                isPositive: true,
                icon: Icons.pets,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedInsightItem({
    required BuildContext context,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isPositive
                              ? AppTheme.getSuccessColor(context)
                              : AppTheme.errorColor)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      change,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isPositive
                                ? AppTheme.getSuccessColor(context)
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
