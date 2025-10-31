import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_provider.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Only show admin menu button for admin users
          Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authNotifierProvider);
              final isAdmin =
                  auth.user?.role == 'ADMIN' || auth.user?.role == 'HR_MANAGER';
              if (!isAdmin) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Open Admin',
                onPressed: () => context.go('/admin/dashboard'),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Appearance',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: scheme.onSurfaceVariant),
            ),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.system,
            groupValue: prefs.mode,
            secondary: const Icon(Icons.brightness_auto_rounded),
            title: const Text('Use system setting'),
            subtitle: const Text('Automatically match device theme'),
            onChanged: (v) =>
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.system),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.light,
            groupValue: prefs.mode,
            secondary: const Icon(Icons.light_mode_rounded),
            title: const Text('Light'),
            onChanged: (v) =>
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.light),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.dark,
            groupValue: prefs.mode,
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text('Dark'),
            onChanged: (v) =>
                ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark),
          ),
          const Divider(),
          const Divider(),
          Consumer(
            builder: (context, ref, _) {
              final auth = ref.watch(authNotifierProvider);
              final userEmail = auth.user?.email;
              return ListTile(
                leading: const Icon(Icons.lock_rounded),
                title: const Text('Change Password'),
                onTap: () {
                  // Navigate to forgot password screen for password change
                  // The user will need to verify via OTP
                  context.push('/forgot-password');
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: scheme.error),
            title: const Text('Logout'),
            onTap: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
