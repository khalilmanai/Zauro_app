import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_animals_provider.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/confirm_modal.dart';

class AdminAnimalsScreen extends ConsumerWidget {
  const AdminAnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animals = ref.watch(adminPendingAnimalsProvider);
    final actions = ref.watch(adminAnimalsActionsProvider);
    return AdminShell(
      title: 'Admin • Animals',
      child: animals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No pending animals'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = list[i];
              final name = a['name'] ?? 'Unnamed';
              final species = a['species'] ?? '-';
              final owner = a['owner']?['firstName'] != null ? '${a['owner']['firstName']} ${a['owner']['lastName']}' : '-';
              final imageUrl = a['imageUrl'] as String?;
              final id = a['id'] as String? ?? '';
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl != null ? Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover) : const Icon(Icons.pets),
                ),
                title: Text(name),
                subtitle: Text('$species • $owner'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () async {
                        final ok = await showConfirmModal(context, title: 'Approve animal', message: 'Are you sure you want to approve this animal?');
                        if (!ok) return;
                        await actions.approve(id);
                        ref.invalidate(adminPendingAnimalsProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.orange),
                      tooltip: 'Reject',
                      onPressed: () async {
                        final ok = await showConfirmModal(context, title: 'Reject animal', message: 'Reject this animal submission?', danger: true, confirmLabel: 'Reject');
                        if (!ok) return;
                        await actions.reject(id);
                        ref.invalidate(adminPendingAnimalsProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () async {
                        final ok = await showConfirmModal(context, title: 'Delete animal', message: 'This action cannot be undone.', danger: true);
                        if (!ok) return;
                        await actions.remove(id);
                        ref.invalidate(adminPendingAnimalsProvider);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

