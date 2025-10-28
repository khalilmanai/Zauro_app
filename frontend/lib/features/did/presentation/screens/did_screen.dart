import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class DidScreen extends ConsumerWidget {
  const DidScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My DID')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                try {
                  final res = await api.getMyDid();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('DID fetched: ${res.data}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Fetch My DID'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final api = ref.read(apiClientProvider);
                try {
                  final res = await api.getMyCredentials();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Credentials: ${res.data}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Get Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}
