import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../comparison/presentation/providers/comparison_provider.dart';
import '../../../comparison/presentation/widgets/comparison_button.dart';
import '../../../recently_viewed/presentation/providers/recently_viewed_provider.dart';
import '../../../reviews/presentation/widgets/product_reviews_section.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_interaction_providers.dart';
import '../providers/product_providers.dart';
import '../providers/recommendation_providers.dart';
import '../viewmodels/product_state.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_purchase_section.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final catalogState = ref.watch(productViewModelProvider).value;
    ref.listen<AsyncValue<ProductEntity?>>(productDetailsProvider(productId), (
      previous,
      next,
    ) {
      next.whenData((product) {
        if (product != null) {
          ref.read(recentlyViewedProvider.notifier).addProduct(product.id);

          // Track product view in Supabase
          ref
              .read(productInteractionRepositoryProvider)
              .recordInteraction(
                productId: product.id,
                interactionType: 'product_view',
              )
              .then((_) {
                ref.invalidate(personalizedRecommendationsProvider);
              })
              .catchError((error) {
                debugPrint('Product view tracking failed: $error');
              });
        }
      });
    });
    final wishlistAsync = ref.watch(wishlistViewModelProvider);

    final wishlistState = wishlistAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (productAsync.value != null)
            IconButton(
              tooltip: 'Share Product',
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                _shareProduct(productAsync.value!);
              },
            ),

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
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading product details...'),
            ],
          ),
        ),

        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load product',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(productDetailsProvider(productId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (product) {
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Not Found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This product may have been removed or is unavailable.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return _buildProductDetails(context, ref, product, catalogState);
        },
      ),
    );
  }

  Widget _buildProductDetails(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
    ProductState? catalogState,
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

                _buildProductInformation(product, catalogState),
                const SizedBox(height: 16),

                const SizedBox(height: 12),

                _buildPrice(context, product),

                const SizedBox(height: 12),

                _buildStockStatus(product),

                const SizedBox(height: 16),

                _buildDeliveryInformation(product),

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

                _buildRelatedProducts(context, ref, product),

                const SizedBox(height: 28),

                ProductPurchaseSection(product: product),
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
        height: 320,
        width: double.infinity,
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 70,
          color: Colors.grey,
        ),
      );
    }

    return ProductImageGallery(
      imageUrls: images.map((image) => image.imageUrl).toList(),
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
    final int quantity = product.stockQuantity;

    final bool isOutOfStock = quantity <= 0;
    final bool isLowStock = quantity > 0 && quantity <= 5;

    final Color statusColor = isOutOfStock
        ? Colors.red
        : isLowStock
        ? Colors.orange
        : Colors.green;

    final String statusText = isOutOfStock
        ? 'Out of Stock'
        : isLowStock
        ? 'Only $quantity left in stock'
        : 'In Stock';

    final IconData statusIcon = isOutOfStock
        ? Icons.cancel_outlined
        : isLowStock
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (!isOutOfStock)
                  Text(
                    '$quantity units available',
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCatalogName(List<Map<String, dynamic>> items, int id) {
    for (final item in items) {
      if ((item['id'] as num?)?.toInt() == id) {
        return item['name'] as String? ?? 'Unknown';
      }
    }

    return 'Unknown';
  }

  Widget _buildProductInformation(
    ProductEntity product,
    ProductState? catalogState,
  ) {
    final brandName = _getCatalogName(
      catalogState?.brands ?? [],
      product.brandId,
    );

    final categoryName = _getCatalogName(
      catalogState?.categories ?? [],
      product.categoryId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.business, size: 16),
              label: Text(brandName),
            ),
            Chip(
              avatar: const Icon(Icons.category_outlined, size: 16),
              label: Text(categoryName),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(Icons.qr_code, size: 18),
            const SizedBox(width: 8),
            const Text('SKU: ', style: TextStyle(fontWeight: FontWeight.w600)),
            Expanded(child: Text(product.sku)),
          ],
        ),

        if (product.specifications.isNotEmpty) ...[
          const SizedBox(height: 20),

          const Text(
            'Product Highlights',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          ...product.specifications.entries.take(4).map((entry) {
            final label = entry.key
                .replaceAll('_', ' ')
                .split(' ')
                .map(
                  (word) => word.isEmpty
                      ? word
                      : '${word[0].toUpperCase()}${word.substring(1)}',
                )
                .join(' ');

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('$label: ${entry.value}')),
                ],
              ),
            );
          }),
        ],
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

  Widget _buildDeliveryInformation(ProductEntity product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Delivery Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select your saved delivery address during checkout '
                  'to view available delivery options.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
          if (product.stockQuantity <= 0) ...[
            const SizedBox(height: 10),
            const Text(
              'This product is currently unavailable for purchase.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(
    BuildContext context,
    WidgetRef ref,
    ProductEntity currentProduct,
  ) {
    final relatedProductsAsync = ref.watch(
      relatedProductsProvider(currentProduct.id),
    );

    return relatedProductsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),

      error: (error, stackTrace) {
        debugPrint('Related products loading failed: $error');
        return const SizedBox.shrink();
      },

      data: (relatedProducts) {
        if (relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Related Products',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 245,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = relatedProducts[index];

                  return GestureDetector(
                    onTap: () {
                      context.push('/product/${product.id}');
                    },
                    child: Container(
                      width: 155,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.25),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: SizedBox(
                              height: 135,
                              width: double.infinity,
                              child: product.images.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.images.first.imageUrl,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) =>
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.image_not_supported),
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  '₹${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareProduct(ProductEntity product) async {
    final productDetails =
        '''
            Check out this product on TechShop!

            ${product.name}

            Price: ₹${product.price.toStringAsFixed(2)}

            ${product.description ?? 'Explore this product on TechShop.'}

        ''';

    await SharePlus.instance.share(
      ShareParams(subject: product.name, text: productDetails),
    );
  }
}
