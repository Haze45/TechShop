import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/reviews/presentation/widgets/product_rating_widget.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final String brand;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final double rating;
  final bool isWishlisted;

  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(10),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image and Wishlist
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,

                        placeholder: (context, url) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },

                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 0,
                      right: 0,

                      child: IconButton(
                        onPressed: onWishlistTap,

                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted
                              ? Colors.red
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Brand
              Text(
                brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 4),

              // Product Name
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              // Rating
              ProductRatingWidget(
                productId: productId,
                starSize: 15,
              ),

              const SizedBox(height: 6),

              // Price
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '₹${price.toStringAsFixed(0)}',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (oldPrice != null) ...[
                    const SizedBox(width: 6),

                    Flexible(
                      child: Text(
                        '₹${oldPrice!.toStringAsFixed(0)}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
