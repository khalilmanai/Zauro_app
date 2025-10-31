import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_stats_provider.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/stats_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    return AdminShell(
      title: 'Admin Dashboard',
      child: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (s) {
          final cols = MediaQuery.of(context).size.width > 1200 ? 4 : 2;
          return GridView.count(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              StatsCard(icon: Icons.people_alt, label: 'Total Users', value: s.users?.toString() ?? '-'),
              StatsCard(icon: Icons.pets, label: 'Pending Animals', value: s.pendingAnimals.toString()),
              StatsCard(icon: Icons.swap_horiz, label: 'Active Trades', value: s.activeTrades.toString()),
              StatsCard(icon: Icons.collections_bookmark, label: 'Total Collections', value: s.collections.toString()),
            ],
          );
        },
      ),
    );
  }
}

