import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_stats_provider.dart';
import '../../data/repositories/admin_repository.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/stats_card.dart';
import '../../../../core/widgets/empty_state.dart';

final adminRecentTradesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final trades = await repo.getAllTrades(page: 1, limit: 5);
  return trades.take(5).toList();
});

final adminRecentAnimalsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final animals = await repo.getPendingAnimals(page: 1, limit: 5);
  return animals.take(5).toList();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final recentTrades = ref.watch(adminRecentTradesProvider);
    final recentAnimals = ref.watch(adminRecentAnimalsProvider);

    return AdminShell(
      title: 'Admin Dashboard',
      child: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (s) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context, s),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRecentTrades(context, ref, recentTrades)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentAnimals(context, ref, recentAnimals)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminStats s) {
    final cols = MediaQuery.of(context).size.width > 1200 ? 5 : MediaQuery.of(context).size.width > 800 ? 3 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        StatsCard(
          icon: Icons.people_alt,
          label: 'Total Users',
          value: s.users?.toString() ?? '-',
          onTap: () => context.go('/admin/dashboard'),
        ),
        StatsCard(
          icon: Icons.pets,
          label: 'Pending Animals',
          value: s.pendingAnimals.toString(),
          onTap: () => context.go('/admin/animals'),
        ),
        StatsCard(
          icon: Icons.swap_horiz,
          label: 'Active Trades',
          value: s.activeTrades.toString(),
          onTap: () => context.go('/admin/trades'),
        ),
        StatsCard(
          icon: Icons.collections_bookmark,
          label: 'Total Collections',
          value: s.collections.toString(),
          onTap: () => context.go('/admin/collections'),
        ),
        StatsCard(
          icon: Icons.verified_user,
          label: 'Credentials',
          value: '-',
          onTap: () => context.go('/admin/dids'),
        ),
      ],
    );
  }

  Widget _buildRecentTrades(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> trades) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Trades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () => context.go('/admin/trades'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            trades.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(icon: Icons.swap_horiz, title: 'No Recent Trades');
                }
                return Column(
                  children: list.map((t) {
                    final id = t['id']?.toString() ?? '-';
                    final status = t['status']?.toString() ?? '-';
                    final price = t['price']?.toString() ?? '-';
                    return ListTile(
                      dense: true,
                      title: Text('Trade $id'),
                      subtitle: Text('Status: $status • Price: $price'),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () => context.go('/admin/trades'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnimals(BuildContext context, WidgetRef ref, AsyncValue<List<Map<String, dynamic>>> animals) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Animals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () => context.go('/admin/animals'), child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            animals.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e'),
              data: (list) {
                if (list.isEmpty) {
                  return const EmptyState(icon: Icons.pets, title: 'No Pending Animals');
                }
                return Column(
                  children: list.map((a) {
                    final name = a['name']?.toString() ?? 'Unnamed';
                    final species = a['species']?.toString() ?? '-';
                    return ListTile(
                      dense: true,
                      leading: a['imageUrl'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(a['imageUrl'], width: 40, height: 40, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.pets),
                      title: Text(name),
                      subtitle: Text(species),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () => context.go('/admin/animals'),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

