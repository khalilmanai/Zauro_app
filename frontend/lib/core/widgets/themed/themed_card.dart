import 'package:flutter/material.dart';
import '../../theme/theme_tokens.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ThemedCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Card(
      elevation: t.elevationMd,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusLg)),
      child: Padding(
        padding: padding ?? EdgeInsets.all(t.spaceLg),
        child: child,
      ),
    );
  }
}

