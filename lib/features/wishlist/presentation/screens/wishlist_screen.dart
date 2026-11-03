import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../products/presentation/widgets/product_card.dart';
import '../viewmodels/wishlist_state.dart';
import '../viewmodels/wishlist_viewmodel.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          wishlistAsync.whenOrNull(
                data: (state) => state.isNotEmpty
                    ? IconButton(
                        onPressed: state.isUpdating
                            ? null
                            : () => _showClearWishlistDialog(context, ref),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Clear Wishlist',
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),

      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Unable to load your wishlist'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(wishlistViewModelProvider);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),

        data: (wishlistState) {
          if (wishlistState.isEmpty) {
            return _buildEmptyWishlist(context);
          }

          return _buildWishlistContent(context, ref, wishlistState);
        },
      ),
    );
  }

  // =========================================
  // WISHLIST CONTENT
  // =========================================

  Widget _buildWishlistContent(
    BuildContext context,
    WidgetRef ref,
    WishlistState wishlistState,
  ) {
    final items = wishlistState.wishlist!.items;

    return Column(
      children: [
        if (wishlistState.isUpdating) const LinearProgressIndicator(),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${wishlistState.totalItems} Saved Products',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final item = items[index];

              return ProductCard(
                product: item.product,
                isWishlisted: true,

                onTap: () {
                  context.push('/product/${item.product.id}');
                },

                onWishlistTap: wishlistState.isUpdating
                    ? null
                    : () {
                        _removeWishlistItem(context, ref, item.productId);
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================
  // REMOVE WISHLIST ITEM
  // =========================================

  Future<void> _removeWishlistItem(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    try {
      await ref
          .read(wishlistViewModelProvider.notifier)
          .removeFromWishlist(productId);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product removed from wishlist.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to remove product. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================
  // EMPTY WISHLIST
  // =========================================

  Widget _buildEmptyWishlist(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 90, color: Colors.grey.shade400),

            const SizedBox(height: 20),

            Text(
              'Your Wishlist is Empty',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Save your favourite smartphones and laptops here.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Explore Products'),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // CLEAR WISHLIST CONFIRMATION
  // =========================================

  void _showClearWishlistDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Wishlist?'),
          content: const Text(
            'Are you sure you want to remove all saved products?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _clearWishlist(context, ref);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // =========================================
  // CLEAR WISHLIST
  // =========================================

  Future<void> _clearWishlist(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(wishlistViewModelProvider.notifier).clearWishlist();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wishlist cleared successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to clear wishlist. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
