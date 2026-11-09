import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../comparison/presentation/providers/comparison_provider.dart';
import '../../../comparison/presentation/widgets/comparison_button.dart';
import '../../../reviews/presentation/widgets/product_reviews_section.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final wishlistAsync = ref.watch(wishlistViewModelProvider);

    final wishlistState = wishlistAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed:
                wishlistAsync.isLoading || wishlistState?.isUpdating == true
                ? null
                : () async {
                    final isWishlisted =
                        wishlistState?.containsProduct(productId) ?? false;

                    try {
                      if (isWishlisted) {
                        await ref
                            .read(wishlistViewModelProvider.notifier)
                            .removeFromWishlist(productId);
                      } else {
                        await ref
                            .read(wishlistViewModelProvider.notifier)
                            .addToWishlist(productId);
                      }

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isWishlisted
                                ? 'Removed from wishlist'
                                : 'Added to wishlist',
                          ),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to update wishlist. Please try again.',
                          ),
                        ),
                      );
                    }
                  },
            icon: Icon(
              wishlistState?.containsProduct(productId) ?? false
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
          ComparisonButton(),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load product: $error')),
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found'));
          }

          return _buildProductDetails(context, ref, product);
        },
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageGallery(product),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                _buildPrice(context, product),

                const SizedBox(height: 12),

                _buildStockStatus(product),

                const SizedBox(height: 16),

                _buildCompareButton(context, ref, product),

                const SizedBox(height: 20),

                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'Specifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                _buildSpecifications(product),

                const SizedBox(height: 28),

                ProductReviewsSection(productId: product.id),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: product.stockQuantity <= 0
                        ? null
                        : () async {
                            try {
                              await ref
                                  .read(cartViewModelProvider.notifier)
                                  .addToCart(
                                    productId: product.id,
                                    quantity: 1,
                                  );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart!',
                                  ),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                      context.push('/cart');
                                    },
                                  ),
                                ),
                              );
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Unable to add product: $error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: Text(
                      product.stockQuantity <= 0
                          ? 'Out of Stock'
                          : 'Add to Cart',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(ProductEntity product) {
    final images = product.images;

    if (images.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 70,
          color: Colors.grey,
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: CachedNetworkImage(
              imageUrl: images[index].imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 60),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrice(BuildContext context, ProductEntity product) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          '₹${product.price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        if (product.hasDiscount) ...[
          Text(
            '₹${product.compareAtPrice!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),

          Text(
            '${product.discountPercentage.toStringAsFixed(0)}% OFF',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(ProductEntity product) {
    return Row(
      children: [
        Icon(
          product.isInStock ? Icons.check_circle : Icons.cancel,
          color: product.isInStock ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          product.isInStock
              ? '${product.stockQuantity} items available'
              : 'Out of stock',
          style: TextStyle(
            color: product.isInStock ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCompareButton(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) {
    final comparisonIds = ref.watch(comparisonProvider);
    final isCompared = comparisonIds.contains(product.id);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          try {
            if (isCompared) {
              ref.read(comparisonProvider.notifier).removeProduct(product.id);
            } else {
              ref
                  .read(comparisonProvider.notifier)
                  .addProduct(product.id, categoryId: product.categoryId);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isCompared
                      ? 'Removed from comparison'
                      : 'Added to comparison',
                ),
              ),
            );
          } catch (error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          }
        },
        icon: Icon(isCompared ? Icons.check : Icons.compare_arrows),
        label: Text(isCompared ? 'Added to Comparison' : 'Add to Compare'),
      ),
    );
  }

  Widget _buildSpecifications(ProductEntity product) {
    if (product.specifications.isEmpty) {
      return const Text('No specifications available.');
    }

    return Column(
      children: product.specifications.entries.map((entry) {
        final label = entry.key
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word.isEmpty
                  ? word
                  : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(flex: 3, child: Text(entry.value.toString())),
            ],
          ),
        );
      }).toList(),
    );
  }
}
