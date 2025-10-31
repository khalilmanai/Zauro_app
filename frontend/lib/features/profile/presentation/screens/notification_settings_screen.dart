import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _tradeUpdates = true;
  bool _animalApprovals = true;
  bool _priceAlerts = false;
  bool _marketplaceUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.grey700),
        ),
      ),
      backgroundColor: AppTheme.grey50,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'General',
            children: [
              SwitchListTile(
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
                title: Text(
                  'Push Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Receive push notifications on your device',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
              SwitchListTile(
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() => _emailNotifications = value);
                },
                title: Text(
                  'Email Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Receive email notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Trading',
            children: [
              SwitchListTile(
                value: _tradeUpdates,
                onChanged: (value) {
                  setState(() => _tradeUpdates = value);
                },
                title: Text(
                  'Trade Updates',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified about trade status changes',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
              SwitchListTile(
                value: _priceAlerts,
                onChanged: (value) {
                  setState(() => _priceAlerts = value);
                },
                title: Text(
                  'Price Alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified when prices change',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
              SwitchListTile(
                value: _marketplaceUpdates,
                onChanged: (value) {
                  setState(() => _marketplaceUpdates = value);
                },
                title: Text(
                  'Marketplace Updates',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified about new marketplace listings',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Animals',
            children: [
              SwitchListTile(
                value: _animalApprovals,
                onChanged: (value) {
                  setState(() => _animalApprovals = value);
                },
                title: Text(
                  'Approval Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Get notified when your animals are approved',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.grey600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
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
}

