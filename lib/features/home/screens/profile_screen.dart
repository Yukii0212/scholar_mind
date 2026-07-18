import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_design.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _savingName = false;
  bool _savingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(firebaseAuthProvider).currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final palette = context.scholarPalette;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScholarSectionHeader(
                  title: 'Profile',
                  subtitle: 'Your ScholarMind account',
                ),
                const Gap(16),
                ScholarPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              _ProfileAvatar(user: user),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: IconButton.filled(
                                  onPressed:
                                      _savingPhoto ? null : _changePhoto,
                                  icon: _savingPhoto
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 18,
                                        ),
                                  tooltip: 'Change profile picture',
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.email ?? 'No email available',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: palette.textMuted),
                                ),
                                const Gap(8),
                                Text(
                                  'Profile details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Display name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        onSubmitted: (_) => _saveName(),
                      ),
                      const Gap(12),
                      FilledButton.icon(
                        onPressed: _savingName ? null : _saveName,
                        icon: _savingName
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                ScholarPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.settings_outlined),
                        title: const Text('Settings'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.go('/settings'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: const Text('Sign out'),
                        onTap: () =>
                            ref.read(authControllerProvider.notifier).signOut(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveName() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    final name = _nameController.text.trim();
    if (user == null || name.isEmpty) return;

    setState(() => _savingName = true);

    try {
      await user.updateDisplayName(name);
      await _saveProfileDocument(
        user: user,
        displayName: name,
        photoUrl: user.photoURL,
      );
      await user.reload();
      if (!mounted) return;
      setState(() {});
      _showMessage('Profile updated.');
    } catch (_) {
      if (mounted) _showMessage('Unable to update profile.');
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _changePhoto() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Images',
          extensions: ['png', 'jpg', 'jpeg'],
          mimeTypes: ['image/png', 'image/jpeg'],
        ),
      ],
    );

    if (file == null) return;

    setState(() => _savingPhoto = true);

    try {
      final bytes = await file.readAsBytes();
      final extension = _extensionFor(file.name);
      final photoUrl = await _uploadProfilePhoto(
        userId: user.uid,
        bytes: bytes,
        extension: extension,
      );

      await user.updatePhotoURL(photoUrl);
      await _saveProfileDocument(
        user: user,
        displayName: user.displayName,
        photoUrl: photoUrl,
      );
      await user.reload();

      if (!mounted) return;
      setState(() {});
      _showMessage('Profile picture updated.');
    } catch (_) {
      if (mounted) _showMessage('Unable to update profile picture.');
    } finally {
      if (mounted) setState(() => _savingPhoto = false);
    }
  }

  Future<String> _uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final reference = FirebaseStorage.instance
        .ref('users/$userId/profile/avatar.$extension');
    final metadata = SettableMetadata(
      contentType: extension == 'png' ? 'image/png' : 'image/jpeg',
    );

    await reference.putData(bytes, metadata);
    return reference.getDownloadURL();
  }

  Future<void> _saveProfileDocument({
    required User user,
    required String? displayName,
    required String? photoUrl,
  }) {
    return FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'displayName': displayName,
        'email': user.email,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  String _extensionFor(String name) {
    final extension = name.split('.').last.toLowerCase();
    return extension == 'png' ? 'png' : 'jpg';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.user,
  });

  final User? user;

  @override
  Widget build(BuildContext context) {
    final url = user?.photoURL;

    return CircleAvatar(
      radius: 42,
      backgroundColor: context.scholarPalette.brandStart,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              (user?.displayName?.trim().isNotEmpty ?? false)
                  ? user!.displayName!.trim()[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}
