import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';

class UploadAnimalImageScreen extends ConsumerStatefulWidget {
  final String animalId;
  const UploadAnimalImageScreen({super.key, required this.animalId});

  @override
  ConsumerState<UploadAnimalImageScreen> createState() => _UploadState();
}

class _UploadState extends ConsumerState<UploadAnimalImageScreen> {
  File? _picked;
  bool _loading = false;

  Future<void> _pick() async {
    final p = ImagePicker();
    final picked = await p.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _picked = File(picked.path));
    }
  }

  Future<void> _upload() async {
    if (_picked == null) return;
    setState(() => _loading = true);
    final api = ref.read(apiClientProvider);
    try {
      // ApiClient expects a File for the @Part parameter; pass the picked File directly
      final res = await api.uploadAnimalImage(widget.animalId, _picked!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload success: ${res.data}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Animal Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_picked != null)
              Image.file(_picked!, width: 200, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                    onPressed: _pick, child: const Text('Pick from gallery')),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: _picked != null && !_loading ? _upload : null,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Upload')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
