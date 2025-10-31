import 'package:flutter/material.dart';

class ThemedInkWell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? hoverColor;

  const ThemedInkWell({super.key, required this.child, this.onTap, this.borderRadius, this.splashColor, this.hoverColor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      splashColor: (splashColor ?? scheme.primary).withOpacity(0.12),
      hoverColor: (hoverColor ?? scheme.primary).withOpacity(0.06),
      highlightColor: scheme.primary.withOpacity(0.08),
      child: child,
    );
  }
}

