import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/confirm_modal.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/status_tag.dart';
import '../../data/repositories/admin_repository.dart';

final adminCollectionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllCollections();
});

final adminCollectionsActionsProvider = Provider<AdminCollectionsActions>((ref) => AdminCollectionsActions(ref.watch(adminRepositoryProvider)));

class AdminCollectionsActions {
  final AdminRepository _repo;
  AdminCollectionsActions(this._repo);

  Future<void> create(Map<String, dynamic> data) => _repo.createCollection(data);
  Future<void> setDefault(String id) => _repo.setCollectionAsDefault(id);
  Future<void> disable(String id) => _repo.disableCollection(id);
  Future<void> rotateIfFull({String? namePrefix, String? symbolPrefix, String? memo}) => _repo.rotateCollectionIfFull(namePrefix: namePrefix, symbolPrefix: symbolPrefix, memo: memo);
}

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(adminCollectionsProvider);
    final actions = ref.watch(adminCollectionsActionsProvider);
    return AdminShell(
      title: 'Admin • Collections',
      actions: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
        onPressed: () => _showCreateCollectionModal(context, ref, actions),
      ),
      child: collections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.collections_bookmark,
              title: 'No Collections',
              description: 'Create your first collection to get started',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create Collection'),
                onPressed: () => _showCreateCollectionModal(context, ref, actions),
              ),
            );
          }
          return _buildCollectionsList(context, ref, list, actions);
        },
      ),
    );
  }

  Widget _buildCollectionsList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> list, AdminCollectionsActions actions) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFilters(context),
          const SizedBox(height: 16),
          ...list.map((c) => _buildCollectionCard(context, ref, c, actions)).toList(),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('Filters', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 16),
          FilterChip(label: const Text('Active'), onSelected: (_) {}, selected: false),
          const SizedBox(width: 8),
          FilterChip(label: const Text('Default'), onSelected: (_) {}, selected: false),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, WidgetRef ref, Map<String, dynamic> c, AdminCollectionsActions actions) {
    final scheme = Theme.of(context).colorScheme;
    final name = c['name'] as String? ?? 'Unnamed';
    final symbol = c['symbol'] as String? ?? '-';
    final currentSupply = c['currentSupply'] as int? ?? 0;
    final maxSupply = c['maxSupply'] as int?;
    final isDefault = c['isDefault'] as bool? ?? false;
    final isActive = c['isActive'] as bool? ?? false;
    final fillPercent = maxSupply != null && maxSupply! > 0 ? (currentSupply / maxSupply!) * 100 : 0.0;
    final id = c['id'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          if (isDefault) StatusTag(status: TagStatus.defaulted, label: 'Default'),
                          if (!isActive) StatusTag(status: TagStatus.disabled),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Symbol: $symbol', style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: !isDefault,
                      child: const Text('Set as Default'),
                      onTap: !isDefault
                          ? () async {
                              final ok = await showConfirmModal(context, title: 'Set Default', message: 'Set this collection as the default?');
                              if (ok) {
                                await actions.setDefault(id);
                                ref.invalidate(adminCollectionsProvider);
                              }
                            }
                          : null,
                    ),
                    PopupMenuItem(
                      enabled: isActive,
                      child: const Text('Disable'),
                      onTap: isActive
                          ? () async {
                              final ok = await showConfirmModal(context, title: 'Disable Collection', message: 'Disable this collection?', danger: true);
                              if (ok) {
                                await actions.disable(id);
                                ref.invalidate(adminCollectionsProvider);
                              }
                            }
                          : null,
                    ),
                    const PopupMenuItem(child: Text('Rotate if Full')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Supply: $currentSupply${maxSupply != null ? ' / $maxSupply' : ''}', style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: fillPercent / 100,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text('${fillPercent.toStringAsFixed(1)}% full', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionModal(BuildContext context, WidgetRef ref, AdminCollectionsActions actions) {
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    final memoController = TextEditingController();
    final maxSupplyController = TextEditingController();
    final isDefaultController = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Collection'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: symbolController,
                decoration: const InputDecoration(labelText: 'Symbol', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: memoController,
                decoration: const InputDecoration(labelText: 'Memo (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxSupplyController,
                decoration: const InputDecoration(labelText: 'Max Supply (optional)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder(
                valueListenable: isDefaultController,
                builder: (context, isDefault, _) => CheckboxListTile(
                  title: const Text('Set as Default'),
                  value: isDefault,
                  onChanged: (v) => isDefaultController.value = v ?? false,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final symbol = symbolController.text.trim();
              if (name.isEmpty || symbol.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Symbol are required')));
                return;
              }
              final maxSupply = maxSupplyController.text.trim().isEmpty ? null : int.tryParse(maxSupplyController.text.trim());
              try {
                await actions.create({
                  'name': name,
                  'symbol': symbol,
                  'memo': memoController.text.trim().isEmpty ? null : memoController.text.trim(),
                  'maxSupply': maxSupply,
                  'isDefault': isDefaultController.value,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(adminCollectionsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Collection created')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}