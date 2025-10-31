import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_shell.dart';
import '../../../../core/widgets/confirm_modal.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/repositories/admin_repository.dart';

final adminCredentialsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getAllCredentials();
});

final adminCredentialsActionsProvider = Provider<AdminCredentialsActions>((ref) => AdminCredentialsActions(ref.watch(adminRepositoryProvider)));

class AdminCredentialsActions {
  final AdminRepository _repo;
  AdminCredentialsActions(this._repo);

  Future<void> issueReputation(Map<String, dynamic> data) => _repo.issueReputationCredential(data);
  Future<void> revoke(String credentialId) => _repo.revokeCredential(credentialId);
}

class AdminDidsScreen extends ConsumerWidget {
  const AdminDidsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentials = ref.watch(adminCredentialsProvider);
    final actions = ref.watch(adminCredentialsActionsProvider);
    return AdminShell(
      title: 'Admin • DIDs & Credentials',
      actions: ElevatedButton.icon(
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Issue Credential'),
        onPressed: () => _showIssueCredentialModal(context, ref, actions),
      ),
      child: credentials.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.verified_user,
              title: 'No Credentials',
              description: 'Issue credentials to users for reputation, KYC, or veterinary records',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Issue Credential'),
                onPressed: () => _showIssueCredentialModal(context, ref, actions),
              ),
            );
          }
          return _buildCredentialsList(context, ref, list, actions);
        },
      ),
    );
  }

  Widget _buildCredentialsList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> list, AdminCredentialsActions actions) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = list[i];
        final id = c['id'] as String? ?? '';
        final type = c['type'] as String? ?? 'Unknown';
        final subject = c['subject'] as String? ?? '';
        final issuedAt = c['issuanceDate'] as String? ?? '';
        final expiresAt = c['expirationDate'] as String? ?? '';

        return ListTile(
          leading: CircleAvatar(
            child: Icon(_getIconForType(type)),
          ),
          title: Text(_getDisplayType(type)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Subject: ${subject.isEmpty ? 'N/A' : subject}'),
              if (issuedAt.isNotEmpty) Text('Issued: ${_formatDate(issuedAt)}'),
              if (expiresAt.isNotEmpty) Text('Expires: ${_formatDate(expiresAt)}'),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('View Details'),
                onTap: () => _showCredentialDetails(context, c),
              ),
              const PopupMenuItem(
                child: Text('Revoke', style: TextStyle(color: Colors.red)),
                value: 'revoke',
              ),
            ],
            onSelected: (value) async {
              if (value == 'revoke') {
                final ok = await showConfirmModal(context, title: 'Revoke Credential', message: 'Revoke this credential?', danger: true);
                if (ok && context.mounted) {
                  await actions.revoke(id);
                  ref.invalidate(adminCredentialsProvider);
                }
              }
            },
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    if (type.toLowerCase().contains('reputation')) return Icons.star;
    if (type.toLowerCase().contains('kyc')) return Icons.verified_user;
    if (type.toLowerCase().contains('veterinary')) return Icons.local_hospital;
    return Icons.credit_card;
  }

  String _getDisplayType(String type) {
    if (type.toLowerCase().contains('reputation')) return 'Reputation Credential';
    if (type.toLowerCase().contains('kyc')) return 'KYC Credential';
    if (type.toLowerCase().contains('veterinary')) return 'Veterinary Credential';
    return type;
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return isoString;
    }
  }

  void _showCredentialDetails(BuildContext context, Map<String, dynamic> c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Credential Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', c['id'] as String? ?? 'N/A'),
              _buildDetailRow('Type', c['type'] as String? ?? 'N/A'),
              _buildDetailRow('Issuer', c['issuer'] as String? ?? 'N/A'),
              _buildDetailRow('Subject', c['subject'] as String? ?? 'N/A'),
              _buildDetailRow('Issued', c['issuanceDate'] as String? ?? 'N/A'),
              _buildDetailRow('Expires', c['expirationDate'] as String? ?? 'N/A'),
              if (c['data'] != null) ...[
                const SizedBox(height: 12),
                const Text('Data:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(c['data'].toString()),
              ],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showIssueCredentialModal(BuildContext context, WidgetRef ref, AdminCredentialsActions actions) {
    final scoreController = TextEditingController(text: '100');
    final totalTradesController = TextEditingController(text: '0');
    final successfulTradesController = TextEditingController(text: '0');
    final averageRatingController = TextEditingController(text: '0.0');
    final subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue Reputation Credential'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'User DID/Subject', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Score', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: totalTradesController,
                decoration: const InputDecoration(labelText: 'Total Trades', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: successfulTradesController,
                decoration: const InputDecoration(labelText: 'Successful Trades', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: averageRatingController,
                decoration: const InputDecoration(labelText: 'Average Rating', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await actions.issueReputation({
                  'score': int.tryParse(scoreController.text) ?? 100,
                  'totalTrades': int.tryParse(totalTradesController.text) ?? 0,
                  'successfulTrades': int.tryParse(successfulTradesController.text) ?? 0,
                  'averageRating': double.tryParse(averageRatingController.text) ?? 0.0,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(adminCredentialsProvider);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credential issued')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Issue'),
          ),
        ],
      ),
    );
  }
}