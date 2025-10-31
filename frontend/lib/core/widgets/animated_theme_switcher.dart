import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class AnimatedThemeSwitcher extends ConsumerWidget {
  final Widget child;
  final Duration duration;

  const AnimatedThemeSwitcher({super.key, required this.child, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeDataProvider);
    return AnimatedTheme(
      data: theme,
      duration: duration,
      curve: Curves.easeInOut,
      child: child,
    );
  }
}

