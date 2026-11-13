import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_interaction_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../providers/comparison_provider.dart';

class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(comparisonProvider);
    final productState = ref.watch(productViewModelProvider).value;
    final brands = productState?.brands ?? [];

    if (selectedIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare Products')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.compare_arrows, size: 70, color: Colors.grey),
              SizedBox(height: 16),
              Text('No products selected for comparison'),
              SizedBox(height: 8),
              Text('Add products using the compare button.'),
            ],
          ),
        ),
      );
    }

    final productAsyncList = selectedIds
        .map((id) => ref.watch(productDetailsProvider(id)))
        .toList();

    final isLoading = productAsyncList.any((item) => item.isLoading);
    final hasError = productAsyncList.any((item) => item.hasError);

    final products = productAsyncList
        .map((item) => item.value)
        .whereType<ProductEntity>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        actions: [
          IconButton(
            tooltip: 'Clear comparison',
            onPressed: () {
              ref.read(comparisonProvider.notifier).clearComparison();
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load comparison products.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      for (final id in selectedIds) {
                        ref.invalidate(productDetailsProvider(id));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildComparison(context, ref, products, brands),
    );
  }

  Widget _buildComparison(
    BuildContext context,
    WidgetRef ref,
    List<ProductEntity> products,
    List<Map<String, dynamic>> brands,
  ) {
    if (products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    final categoryIds = products.map((p) => p.categoryId).toSet();

    if (categoryIds.length > 1) {
      return _buildCategoryMismatch(context, ref, products);
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Products (${products.length}/4)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            _buildProductCards(context, ref, products, brands),

            const SizedBox(height: 28),

            Text(
              'Specification Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            _buildSpecificationsTable(context, products),

            const SizedBox(height: 24),

            Text(
              'Product Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            _buildBasicComparisonTable(context, products, brands),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryMismatch(
    BuildContext context,
    WidgetRef ref,
    List<ProductEntity> products,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.warning_amber_rounded, size: 55, color: Colors.orange),
        const SizedBox(height: 12),
        Text(
          'Different product categories selected',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        const Text(
          'Please remove products from other categories. '
          'Smartphones can only be compared with smartphones, '
          'and laptops with laptops.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...products.map(
          (product) => ListTile(
            title: Text(product.name),
            subtitle: Text('Category ID: ${product.categoryId}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(comparisonProvider.notifier).removeProduct(product.id);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            ref.read(comparisonProvider.notifier).clearComparison();
          },
          child: const Text('Clear Comparison'),
        ),
      ],
    );
  }

  Widget _buildProductCards(
    BuildContext context,
    WidgetRef ref,
    List<ProductEntity> products,
    List<Map<String, dynamic>> brands,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: products.map((product) {
          final primaryImages = product.images.where(
            (image) => image.isPrimary,
          );

          final imageUrl = product.images.isEmpty
              ? null
              : (primaryImages.isNotEmpty
                    ? primaryImages.first.imageUrl
                    : product.images.first.imageUrl);

          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  child: imageUrl == null
                      ? const Icon(Icons.image_not_supported, size: 50)
                      : CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.broken_image),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Brand: ${_getBrandName(product.brandId, brands)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
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

                              try {
                                await ref
                                    .read(productInteractionRepositoryProvider)
                                    .recordInteraction(
                                      productId: product.id,
                                      interactionType: 'add_to_cart',
                                    );
                              } catch (error) {
                                debugPrint(
                                  'Add-to-cart tracking failed: $error',
                                );
                              }

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart!',
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

                TextButton.icon(
                  onPressed: () {
                    ref
                        .read(comparisonProvider.notifier)
                        .removeProduct(product.id);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecificationsTable(
    BuildContext context,
    List<ProductEntity> products,
  ) {
    final allKeys = <String>{};

    for (final product in products) {
      allKeys.addAll(product.specifications.keys);
    }

    if (allKeys.isEmpty) {
      return const Text('No specifications available.');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Specification')),
          ...products.map(
            (product) => DataColumn(
              label: SizedBox(
                width: 130,
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
        rows: allKeys.map((key) {
          final values = products
              .map(
                (product) =>
                    product.specifications[key]?.toString() ?? 'Not specified',
              )
              .toSet();

          final hasDifference = values.length > 1;

          return DataRow(
            cells: [
              DataCell(
                Text(
                  _formatLabel(key),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              ...products.map((product) {
                final value =
                    product.specifications[key]?.toString() ?? 'Not specified';

                return DataCell(
                  Container(
                    width: 130,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasDifference
                          ? Theme.of(context).colorScheme.primaryContainer
                                .withValues(alpha: 0.35)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBasicComparisonTable(
    BuildContext context,
    List<ProductEntity> products,
    List<Map<String, dynamic>> brands,
  ) {
    final rows = <String, String Function(ProductEntity)>{
      'Price': (p) => '₹${p.price.toStringAsFixed(0)}',
      'Original Price': (p) => p.compareAtPrice == null
          ? 'Not available'
          : '₹${p.compareAtPrice!.toStringAsFixed(0)}',
      'Brand': (p) => _getBrandName(p.brandId, brands),
      'Stock': (p) => p.isInStock ? 'In Stock' : 'Out of Stock',
      'Stock Quantity': (p) => p.stockQuantity.toString(),
      'SKU': (p) => p.sku,
      'Featured': (p) => p.isFeatured ? 'Yes' : 'No',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Details')),
          ...products.map(
            (p) => DataColumn(
              label: SizedBox(
                width: 130,
                child: Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
        rows: rows.entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(Text(entry.key)),
              ...products.map((p) => DataCell(Text(entry.value(p)))),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getBrandName(int brandId, List<Map<String, dynamic>> brands) {
    for (final brand in brands) {
      final id = (brand['id'] as num?)?.toInt();

      if (id == brandId) {
        return brand['name']?.toString() ?? 'Unknown Brand';
      }
    }

    return 'Brand #$brandId';
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}
