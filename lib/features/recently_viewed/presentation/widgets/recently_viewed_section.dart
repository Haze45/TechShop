import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/recently_viewed_provider.dart';

class RecentlyViewedSection extends ConsumerWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productIds = ref.watch(recentlyViewedProvider);

    if (productIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final productsAsync = productIds
        .map((id) => ref.watch(productDetailsProvider(id)))
        .toList();

    final products = productsAsync
        .map((item) => item.value)
        .whereType<ProductEntity>()
        .toList();

    if (products.isEmpty) {
      if (productsAsync.every((item) => item.hasError)) {
        return const SizedBox.shrink();
      }
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recently Viewed',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/recently-viewed'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 225,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              final imageUrl = product.images.isNotEmpty
                  ? product.images.first.imageUrl
                  : null;

              return GestureDetector(
                onTap: () {
                  context.push('/product/${product.id}');
                },
                child: Container(
                  width: 155,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: imageUrl == null
                              ? const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 45,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.broken_image),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
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
  }
}
