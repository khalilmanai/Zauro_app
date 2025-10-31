import 'package:flutter/material.dart';

enum TagStatus { pending, approved, rejected, active, disabled, defaulted }

class StatusTag extends StatelessWidget {
  final TagStatus status;
  final String? label;
  final String size; // sm, md
  const StatusTag({super.key, required this.status, this.label, this.size = 'sm'});

  @override
  Widget build(BuildContext context) {
    final tuple = _styleFor(status, Theme.of(context).colorScheme);
    final padding = size == 'md' ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6) : const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final textStyle = size == 'md' ? const TextStyle(fontSize: 12, fontWeight: FontWeight.w600) : const TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tuple.$2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tuple.$1.withOpacity(0.2)),
      ),
      child: Text(label ?? _label(status), style: textStyle.copyWith(color: tuple.$1)),
    );
  }

  static (Color, Color) _styleFor(TagStatus s, ColorScheme scheme) {
    switch (s) {
      case TagStatus.pending:
        return (Colors.orange.shade800, Colors.orange.shade50);
      case TagStatus.approved:
        return (Colors.green.shade800, Colors.green.shade50);
      case TagStatus.rejected:
        return (Colors.red.shade800, Colors.red.shade50);
      case TagStatus.active:
        return (Colors.blue.shade800, Colors.blue.shade50);
      case TagStatus.disabled:
        return (scheme.onSurfaceVariant, scheme.surfaceVariant);
      case TagStatus.defaulted:
        return (Colors.purple.shade800, Colors.purple.shade50);
    }
  }

  static String _label(TagStatus s) {
    switch (s) {
      case TagStatus.pending:
        return 'Pending';
      case TagStatus.approved:
        return 'Approved';
      case TagStatus.rejected:
        return 'Rejected';
      case TagStatus.active:
        return 'Active';
      case TagStatus.disabled:
        return 'Disabled';
      case TagStatus.defaulted:
        return 'Default';
    }
  }
}


