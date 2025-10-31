import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  Color get _statusColor {
    switch (status.toUpperCase()) {
      case 'LISTED':
      case 'ACTIVE':
        return AppTheme.successColor;
      case 'PENDING':
        return AppTheme.warning;
      case 'COMPLETED':
      case 'SOLD':
        return AppTheme.primaryColor;
      case 'CANCELLED':
        return AppTheme.errorColor;
      default:
        return AppTheme.grey600;
    }
  }

  String get _statusText {
    switch (status.toUpperCase()) {
      case 'LISTED':
      case 'ACTIVE':
        return 'Listed';
      case 'PENDING':
        return 'Pending';
      case 'COMPLETED':
        return 'Sold';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        _statusText,
        style: GoogleFonts.poppins(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: _statusColor,
        ),
      ),
    );
  }
}

