import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_info_provider.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appInfoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About TechShop')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),

          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'TechShop',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your destination for smartphones and laptops.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 32),

          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.devices_outlined),
                  title: Text('What We Offer'),
                  subtitle: Text(
                    'Explore smartphones and laptops from different brands.',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.shopping_cart_outlined),
                  title: Text('Shopping Experience'),
                  subtitle: Text(
                    'Browse products, compare specifications, '
                    'manage wishlists and track orders.',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.support_agent_outlined),
                  title: Text('Customer Support'),
                  subtitle: Text(
                    'Get assistance through our customer support system.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: appInfoAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stackTrace) => const Text('Version unavailable'),
              data: (info) => Text(
                'Version ${info.version} (${info.buildNumber})',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              '© ${DateTime.now().year} TechShop. All rights reserved.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
