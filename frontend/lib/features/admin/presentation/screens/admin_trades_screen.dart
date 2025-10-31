import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_trades_provider.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/confirm_modal.dart';

class AdminTradesScreen extends ConsumerWidget {
  const AdminTradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(adminTradesProvider);
    final actions = ref.watch(adminTradesActionsProvider);
    return AdminShell(
      title: 'Admin • Trades',
      child: trades.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No trades'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = list[i];
              final id = t['id']?.toString() ?? '';
              final status = t['status']?.toString() ?? '-';
              final price = t['price']?.toString() ?? '-';
              final animalName = t['animal']?['name']?.toString() ?? '-';
              return ListTile(
                title: Text(animalName),
                subtitle: Text('Status: $status • Price: $price'),
                trailing: status == 'LISTED' || status == 'ACTIVE'
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        tooltip: 'Cancel trade',
                        onPressed: () async {
                          final ok = await showConfirmModal(context, title: 'Cancel trade', message: 'Cancel this trade as fraudulent?', danger: true, confirmLabel: 'Cancel');
                          if (!ok) return;
                          await actions.cancel(id);
                          ref.invalidate(adminTradesProvider);
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

