import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: 'Frequently Asked Questions',
              children: [
                _buildFAQItem(
                  context,
                  'How do I create an NFT for my animal?',
                  'Go to Animals > Add Animal, fill in the animal details, upload an image, and submit. Once approved by an expert, you can mint the NFT.',
                ),
                _buildFAQItem(
                  context,
                  'How do I list an animal for sale?',
                  'After your animal is approved and minted, go to the animal detail page and click "List for Trade". Set your price in HBAR.',
                ),
                _buildFAQItem(
                  context,
                  'What is the minting fee?',
                  'Minting fees are handled through the Hedera network. Check your wallet balance to ensure you have enough HBAR.',
                ),
                _buildFAQItem(
                  context,
                  'How do I buy an animal?',
                  'Browse the marketplace, select an animal, review the details, and click "Buy Now". Confirm the purchase in the dialog.',
                ),
                _buildFAQItem(
                  context,
                  'Can I edit my animal after listing?',
                  'Once an animal is approved and listed, you cannot edit its details. Only animals pending review can be edited.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Contact Support',
              children: [
                _buildContactItem(
                  context,
                  icon: Icons.email,
                  title: 'Email Support',
                  subtitle: 'support@zauro.com',
                  onTap: () => _launchEmail(context),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.phone,
                  title: 'Phone Support',
                  subtitle: '+1 (555) 123-4567',
                  onTap: () => _launchPhone(context),
                ),
                _buildContactItem(
                  context,
                  icon: Icons.language,
                  title: 'Visit Website',
                  subtitle: 'www.zauro.com',
                  onTap: () => _launchWebsite(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Resources',
              children: [
                _buildResourceItem(
                  context,
                  'User Guide',
                  'Learn how to use all features of the marketplace',
                  Icons.book,
                ),
                _buildResourceItem(
                  context,
                  'Tutorial Videos',
                  'Watch step-by-step video tutorials',
                  Icons.play_circle,
                ),
                _buildResourceItem(
                  context,
                  'Terms of Service',
                  'Read our terms and conditions',
                  Icons.description,
                ),
                _buildResourceItem(
                  context,
                  'Privacy Policy',
                  'Understand how we protect your data',
                  Icons.privacy_tip,
                ),
              ],
            ),
          ],
        ),
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
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    String question,
    String answer,
  ) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.grey900,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.grey600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppTheme.grey600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey400),
      onTap: onTap,
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppTheme.grey600,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.grey400),
      onTap: () {
        // TODO: Navigate to resource or open URL
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title coming soon'),
            backgroundColor: AppTheme.grey600,
          ),
        );
      },
    );
  }

  void _launchEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email: support@zauro.com'),
        duration: const Duration(seconds: 3),
      ),
    );
    // TODO: Implement email launcher when url_launcher package is added
  }

  void _launchPhone(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Phone: +1 (555) 123-4567'),
        duration: const Duration(seconds: 3),
      ),
    );
    // TODO: Implement phone launcher when url_launcher package is added
  }

  void _launchWebsite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Website: www.zauro.com'),
        duration: const Duration(seconds: 3),
      ),
    );
    // TODO: Implement website launcher when url_launcher package is added
  }
}

