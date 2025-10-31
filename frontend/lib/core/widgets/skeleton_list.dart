import 'package:flutter/material.dart';

class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 8});

  @override
  Widget build(BuildContext context) {
    final shimmer = Theme.of(context).colorScheme.surfaceVariant;
    return ListView.separated(
      itemCount: count,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        return ListTile(
          leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(8))),
          title: Container(height: 14, color: shimmer),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(height: 12, color: shimmer),
          ),
        );
      },
    );
  }
}


