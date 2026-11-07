import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_providers.dart';

final profileAvatarUrlProvider = FutureProvider.autoDispose<String?>((ref) {
  return ref.read(authRepositoryProvider).getAvatarSignedUrl();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authViewModelProvider.notifier).signOut();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logout failed: $error')));
      }
    }
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref, {
    required String fullName,
    required String phone,
  }) async {
    final nameController = TextEditingController(text: fullName);
    final phoneController = TextEditingController(text: phone);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!context.mounted) return;

      if (nameController.text.trim().isEmpty ||
          phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields.')),
        );
      } else {
        try {
          await ref
              .read(authViewModelProvider.notifier)
              .updateProfile(
                fullName: nameController.text,
                phone: phoneController.text,
              );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
        } catch (error) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to update profile: $error')),
          );
        }
      }
    }

    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> _changeAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
      );

      if (image == null) return;

      final Uint8List imageBytes = await image.readAsBytes();

      await ref
          .read(authViewModelProvider.notifier)
          .uploadAvatar(imageBytes: imageBytes, fileName: image.name);

      ref.invalidate(profileAvatarUrlProvider);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update profile picture: $error')),
      );
    }
  }

  Widget profileAvatar(WidgetRef ref) {
    final avatarState = ref.watch(profileAvatarUrlProvider);

    return avatarState.when(
      loading: () =>
          const CircleAvatar(radius: 48, child: CircularProgressIndicator()),
      error: (_, _) =>
          const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 50)),
      data: (avatarUrl) => CircleAvatar(
        radius: 48,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('You are not logged in.'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    profileAvatar(ref),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _changeAvatar(context, ref),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  user.email ?? 'No email available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Full Name'),
                      subtitle: Text(user.fullName ?? 'Not available'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email ?? 'Not available'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Phone'),
                      subtitle: Text(user.phone ?? 'Not available'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () => _editProfile(
                  context,
                  ref,
                  fullName: user.fullName ?? '',
                  phone: user.phone ?? '',
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
              ),

              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('My Addresses'),
                subtitle: const Text('Manage delivery addresses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  context.push('/addresses');
                },
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () => _logout(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
