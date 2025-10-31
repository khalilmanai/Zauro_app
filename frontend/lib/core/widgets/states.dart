import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, required this.title, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1),
            duration: Anim.microSlow,
            curve: Anim.emphasis,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Icon(Icons.error_outline, size: 64, color: scheme.error),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}

class SuccessState extends StatelessWidget {
  final String title;
  final String? message;

  const SuccessState({super.key, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: Anim.micro,
            curve: Anim.emphasis,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Icon(Icons.check_circle, size: 64, color: scheme.primary),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

