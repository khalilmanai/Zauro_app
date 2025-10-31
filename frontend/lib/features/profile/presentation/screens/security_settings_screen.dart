import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
        ),
      ),
      backgroundColor: AppTheme.grey50,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Password',
            children: [
              ListTile(
                leading: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                title: Text(
                  'Change Password',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Update your account password',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey400),
                onTap: () {
                  context.push('/forgot-password');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Two-Factor Authentication',
            children: [
              ListTile(
                leading: Icon(Icons.security, color: AppTheme.primaryColor),
                title: Text(
                  '2FA Status',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Not enabled',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement 2FA toggle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('2FA feature coming soon'),
                        backgroundColor: AppTheme.grey600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Session Management',
            children: [
              ListTile(
                leading: Icon(Icons.devices, color: AppTheme.primaryColor),
                title: Text(
                  'Active Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Manage your active login sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey400),
                onTap: () {
                  // TODO: Show active sessions
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Session management coming soon'),
                      backgroundColor: AppTheme.grey600,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: AppTheme.errorColor),
                title: Text(
                  'Sign Out All Devices',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.errorColor,
                  ),
                ),
                subtitle: Text(
                  'Sign out from all devices',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
                onTap: () {
                  _showSignOutAllDialog(context, ref);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getLightShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showSignOutAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out All Devices',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will sign you out from all devices. You will need to sign in again on this device.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(
              'Sign Out All',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

