import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../products/presentation/providers/product_providers.dart';
import '../providers/recently_viewed_provider.dart';

class RecentlyViewedScreen extends ConsumerWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyViewedIds = ref.watch(recentlyViewedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Viewed'),
        actions: [
          if (recentlyViewedIds.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearHistory(context, ref),
            ),
        ],
      ),
      body: recentlyViewedIds.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recentlyViewedIds.length,
              itemBuilder: (context, index) {
                final productId = recentlyViewedIds[index];

                return _RecentlyViewedProduct(productId: productId);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 70,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Recently Viewed Products',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Products you view will appear here.'),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear History?'),
          content: const Text(
            'Are you sure you want to remove all recently viewed products?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(recentlyViewedProvider.notifier).clearHistory();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recently viewed history cleared.'),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

class _RecentlyViewedProduct extends ConsumerWidget {
  final String productId;

  const _RecentlyViewedProduct({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));

    return productAsync.when(
      loading: () =>
          const Card(child: ListTile(title: LinearProgressIndicator())),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (product) {
        if (product == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: const CircleAvatar(
              child: Icon(Icons.shopping_bag_outlined),
            ),
            title: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '₹${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Remove product',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref
                        .read(recentlyViewedProvider.notifier)
                        .removeProduct(product.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product removed from history.'),
                      ),
                    );
                  },
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              context.push('/product/${product.id}');
            },
          ),
        );
      },
    );
  }
}
