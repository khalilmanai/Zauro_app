import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../shared/presentation/widgets/custom_button.dart';

class ReceiveQrDialog extends StatelessWidget {
  final String hederaAccountId;

  const ReceiveQrDialog({
    super.key,
    required this.hederaAccountId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.grey900 : AppTheme.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.qr_code,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Receive HBAR',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon:
                      Icon(Icons.close, color: AppTheme.getTextColor(context)),
                ),
              ],
            ),

            SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.grey900 : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.grey700 : AppTheme.grey200,
                  width: 1,
                ),
              ),
              child: QrImageView(
                data: hederaAccountId,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: isDark ? AppTheme.grey900 : AppTheme.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.getTextColor(context),
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Account ID
            Text(
              'Your Hedera Account ID',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.getMutedTextColor(context),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.grey800 : AppTheme.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.grey700 : AppTheme.grey200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hederaAccountId,
                      style: GoogleFonts.robotoMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'How to receive HBAR',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Share this QR code or account ID with the sender\n'
                    '• Only accept HBAR transfers to this account\n'
                    '• Verify the sender before confirming large amounts',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.getMutedTextColor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.grey600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: () => _copyToClipboard(context),
                    text: 'Copy Account ID',
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: hederaAccountId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account ID copied to clipboard!',
          style: GoogleFonts.poppins(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
