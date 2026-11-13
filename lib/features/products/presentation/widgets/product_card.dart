import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../comparison/presentation/providers/comparison_provider.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isWishlisted = false,
    this.onWishlistTap,
  });

  String get _primaryImage {
    if (product.images.isEmpty) return '';

    final primaryImages = product.images.where((image) => image.isPrimary);

    if (primaryImages.isNotEmpty) {
      return primaryImages.first.imageUrl;
    }

    return product.images.first.imageUrl;
  }

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = _primaryImage;

    final comparisonIds = ref.watch(comparisonProvider);
    final isCompared = comparisonIds.contains(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: imageUrl.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 45,
                              color: Colors.grey,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,

                            // Reduce decoded image memory usage.
                            memCacheWidth: 400,
                            memCacheHeight: 400,

                            // Limit the size of the cached disk image.
                            maxWidthDiskCache: 600,
                            maxHeightDiskCache: 600,

                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),

                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 45,
                              ),
                            ),
                          ),
                  ),

                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: onWishlistTap,
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        tooltip: isWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: isCompared
                            ? 'Remove from comparison'
                            : 'Compare product',
                        icon: Icon(
                          isCompared
                              ? Icons.compare_arrows
                              : Icons.compare_arrows_outlined,
                          color: isCompared ? Colors.blue : Colors.grey,
                        ),
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          try {
                            if (isCompared) {
                              ref
                                  .read(comparisonProvider.notifier)
                                  .removeProduct(product.id);
                            } else {
                              ref
                                  .read(comparisonProvider.notifier)
                                  .addProduct(
                                    product.id,
                                    categoryId: product.categoryId,
                                  );
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  if (!product.isInStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _formatPrice(product.price),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatPrice(product.compareAtPrice!),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.isInStock ? 'In Stock' : 'Currently unavailable',
                    style: TextStyle(
                      color: product.isInStock ? Colors.green : Colors.red,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
