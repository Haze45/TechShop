import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../viewmodels/cart_state.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          cartAsync.whenOrNull(
                data: (state) => state.isNotEmpty
                    ? IconButton(
                        onPressed: state.isUpdating
                            ? null
                            : () => _showClearCartDialog(context, ref),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Clear Cart',
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Unable to load your cart'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(cartViewModelProvider);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (cartState) {
          if (cartState.isEmpty) {
            return _buildEmptyCart(context);
          }

          final cart = cartState.cart!;

          return Column(
            children: [
              if (cartState.isUpdating) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    return ref.read(cartViewModelProvider.notifier).loadCart();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return _buildCartItem(context, ref, item, cartState);
                    },
                  ),
                ),
              ),

              _buildCartSummary(context, cartState),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runCartAction(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCartItem(
    BuildContext context,
    WidgetRef ref,
    CartItemEntity item,
    CartState cartState,
  ) {
    final product = item.product;

    final primaryImage = product.images.isNotEmpty
        ? (product.images.where((image) => image.isPrimary).isNotEmpty
              ? product.images.firstWhere((image) => image.isPrimary).imageUrl
              : product.images.first.imageUrl)
        : null;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 95,
                height: 110,
                color: Colors.grey.shade100,
                child: primaryImage != null
                    ? CachedNetworkImage(
                        imageUrl: primaryImage,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 35,
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 35),
              ),
            ),

            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '₹${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (!item.isInStock)
                    const Text(
                      'Insufficient stock',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    )
                  else
                    Text(
                      '${item.product.stockQuantity - item.quantity} available',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),

                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: cartState.isUpdating
                            ? null
                            : () => _runCartAction(
                                context,
                                () => ref
                                    .read(cartViewModelProvider.notifier)
                                    .decreaseQuantity(item.id, item.quantity),
                              ),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),

                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed:
                            cartState.isUpdating || !item.canIncreaseQuantity
                            ? null
                            : () => _runCartAction(
                                context,
                                () => ref
                                    .read(cartViewModelProvider.notifier)
                                    .increaseQuantity(item.id, item.quantity),
                              ),
                        icon: const Icon(Icons.add_circle_outline),
                      ),

                      const Spacer(),

                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: cartState.isUpdating
                            ? null
                            : () => _runCartAction(
                                context,
                                () => ref
                                    .read(cartViewModelProvider.notifier)
                                    .removeItem(item.id),
                              ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    'Subtotal: ₹${item.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Items'),
              Text('${cartState.totalItems}'),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${cartState.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  cartState.isUpdating ||
                      cartState.cart!.items.any((item) => !item.isInStock)
                  ? null
                  : () {
                      context.push('/checkout');
                    },
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              'Your Cart is Empty',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cart?'),
          content: const Text(
            'Are you sure you want to remove all products from your cart?',
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

                _runCartAction(
                  context,
                  () => ref.read(cartViewModelProvider.notifier).clearCart(),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
