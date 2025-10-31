import 'package:flutter/material.dart';

class ThemedRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ThemedRefreshIndicator({super.key, required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator.adaptive(
      color: scheme.primary,
      backgroundColor: scheme.surface,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

