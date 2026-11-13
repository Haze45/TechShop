import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/theme_provider.dart';
import '../providers/notification_preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.settings_brightness;
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(themeModeProvider);
    final notificationPreferencesAsync = ref.watch(
      notificationPreferencesProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: selectedTheme,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
              },
              child: Column(
                children: ThemeMode.values.map((mode) {
                  return RadioListTile<ThemeMode>(
                    value: mode,
                    secondary: Icon(_themeIcon(mode)),
                    title: Text(_themeLabel(mode)),
                    subtitle: Text(
                      mode == ThemeMode.system
                          ? 'Follow your device appearance'
                          : mode == ThemeMode.light
                          ? 'Always use light appearance'
                          : 'Always use dark appearance',
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 10),

          Card(
            child: notificationPreferencesAsync.when(
              loading: () => const ListTile(
                leading: Icon(Icons.notifications_outlined),
                title: Text('Order Updates'),
                subtitle: Text('Loading preferences...'),
                trailing: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stackTrace) => ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Order Updates'),
                subtitle: const Text('Unable to load notification preferences'),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(notificationPreferencesProvider);
                  },
                ),
              ),
              data: (preferences) => SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Order Updates'),
                subtitle: const Text(
                  'Receive notifications about your order status',
                ),
                value: preferences.orderUpdatesEnabled,
                onChanged: (enabled) async {
                  try {
                    await ref
                        .read(notificationPreferencesRepositoryProvider)
                        .updateOrderNotifications(enabled);

                    ref.invalidate(notificationPreferencesProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            enabled
                                ? 'Order notifications enabled'
                                : 'Order notifications disabled',
                          ),
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Unable to update preference: $error'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('My Profile'),
                  subtitle: const Text('Manage your personal information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/profile'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/change-password'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('My Addresses'),
                  subtitle: const Text('Manage delivery addresses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/addresses'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text('Shopping', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('My Orders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/orders'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('My Wishlist'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/wishlist'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Customer Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/support'),
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About TechShop'),
                  subtitle: const Text('App information and version'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/about'),
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('How we handle your information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/privacy-policy'),
                ),

                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms & Conditions'),
                  subtitle: const Text('Rules for using TechShop'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/terms-conditions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
