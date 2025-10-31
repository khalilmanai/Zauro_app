import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../shared/presentation/widgets/loading_overlay.dart';
import '../../../animals/providers/animals_provider.dart';
import '../../../trading/providers/trading_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey900,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(
                  user?.fullName ?? 'User', user?.email ?? '', user?.avatarUrl),
              const SizedBox(height: 24),
              _buildProfileStats(ref),
              const SizedBox(height: 24),
              _buildMenuSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String? avatarUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: avatarUrl != null
                ? (avatarUrl.startsWith('http')
                    ? NetworkImage(avatarUrl)
                    : null)
                : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.poppins(fontSize: 16, color: AppTheme.grey600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Verified Account',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats(WidgetRef ref) {
    final animalsState = ref.watch(myAnimalsProvider);
    final tradesState = ref.watch(myTradesProvider);

    final animalsCount = animalsState.when(
      data: (animals) => animals.length.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

    final tradesCount = tradesState.when(
      data: (trades) => trades.length.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

    // Rating might not be available yet, showing placeholder
    return Row(
      children: [
        Expanded(child: _buildStatCard('Animals', animalsCount, Icons.pets)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Trades', tradesCount, Icons.swap_horiz)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Rating', '—', Icons.star)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.grey900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // Navigate to edit profile screen
              context.push('/profile/edit');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security,
            title: 'Security Settings',
            onTap: () {
              context.push('/profile/security');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              context.push('/profile/notifications');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              context.push('/help');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => _showAboutDialog(context),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            textColor: AppTheme.errorColor,
            onTap: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.grey700),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.grey900,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.grey400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppTheme.grey200);
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ref.read(authNotifierProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              'About Zauro Marketplace',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppConfig.appVersion}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Zauro Marketplace is a blockchain-powered platform for trading livestock as NFTs on the Hedera network.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: AppTheme.grey300),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                // TODO: Open terms URL
              },
              icon: Icon(Icons.description, size: 20),
              label: Text(
                'Terms of Service',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Open privacy policy URL
              },
              icon: Icon(Icons.privacy_tip, size: 20),
              label: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
