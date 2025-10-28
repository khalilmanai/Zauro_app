import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collections (Admin)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                try {
                  final res = await api.listCollections();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Collections: ${res.data}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Load Collections'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                try {
                  final res = await api.getDefaultCollection();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Default: ${res.data}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Get Default Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
