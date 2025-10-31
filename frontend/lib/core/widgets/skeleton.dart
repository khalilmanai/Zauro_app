import 'package:flutter/material.dart';
import '../animations/micro_interactions.dart';

class Skeleton extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;

  const Skeleton({super.key, required this.height, required this.width, this.borderRadius = const BorderRadius.all(Radius.circular(12))});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Shimmer(
        builder: (context, t) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  base,
                  Color.lerp(base, highlight, 0.4)!,
                  base,
                ],
                stops: const [0.2, 0.5, 0.8],
                transform: GradientRotation(t * 6.283185307179586),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  const SkeletonList({super.key, this.count = 6, this.itemHeight = 64});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const Skeleton(height: 64, width: double.infinity),
    );
  }
}

