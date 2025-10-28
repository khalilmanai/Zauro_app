import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/storage_service.dart';
import '../../../auth/presentation/widgets/avatar_selection_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/data/models/auth_models.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSaving = false;
  String? _avatarUrl;
  File? _localImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _avatarUrl = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _localImage = File(picked.path);
        _avatarUrl = _localImage!.path; // local preview path
      });
    }
  }

  void _onAvatarSelected(Avatar avatar) {
    setState(() {
      _avatarUrl = avatar.imageUrl;
      _localImage = null;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      // Update in-memory auth state for immediate UX
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final current = ref.read(authNotifierProvider).user;
      if (current != null) {
        final updated = current.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          avatarUrl: _avatarUrl,
        );

        // Update notifier state via provided helper so persistence is handled consistently
        await authNotifier.updateLocalUser(updated);

        // Persist avatar url separately for best-effort persistence
        try {
          if (updated.avatarUrl != null) {
            await StorageService.setString(
                'user_avatar_url', updated.avatarUrl!);
          } else {
            await StorageService.remove('user_avatar_url');
          }
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      backgroundColor: AppTheme.grey50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.getLightShadow(),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.08),
                        backgroundImage: _localImage != null
                            ? FileImage(_localImage!) as ImageProvider
                            : (_avatarUrl != null &&
                                    _avatarUrl!.startsWith('http')
                                ? NetworkImage(_avatarUrl!)
                                : null),
                        child: (_avatarUrl == null && _localImage == null)
                            ? Text(
                                (_firstNameController.text.isNotEmpty
                                    ? _firstNameController.text[0].toUpperCase()
                                    : 'U'),
                                style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            // Show modal for choosing avatar or gallery
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => SizedBox(
                                height: 360,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Choose from gallery'),
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        _pickFromGallery();
                                      },
                                    ),
                                    const Divider(height: 1),
                                    Expanded(
                                      child: AvatarSelectionWidget(
                                        selectedAvatar: null,
                                        onAvatarSelected: (a) {
                                          Navigator.of(ctx).pop();
                                          _onAvatarSelected(a);
                                        },
                                        avatars: const [],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.getLightShadow(),
                            ),
                            child: const Icon(Icons.edit, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap edit to choose an avatar or upload from your device',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppTheme.grey600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.getLightShadow(),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Save',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
