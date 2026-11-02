
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authViewModelProvider.notifier).signOut();

      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: authState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('You are not logged in.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 45),
                ),
                const SizedBox(height: 20),

                Text(
                  user.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),

                Text('Email: ${user.email ?? 'Not available'}'),
                const SizedBox(height: 8),

                Text('Phone: ${user.phone ?? 'Not available'}'),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
