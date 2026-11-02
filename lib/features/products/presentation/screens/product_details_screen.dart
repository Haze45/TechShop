
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Unable to load product: $error'),
        ),
        data: (product) {
          if (product == null) {
            return const Center(
              child: Text('Product not found'),
            );
          }

          return _buildProductDetails(context, product);
        },
      ),
    );
  }

  Widget _buildProductDetails(
      BuildContext context,
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

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: product.isInStock
                        ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cart functionality will be added in the Cart phase.',
                          ),
                        ),
                      );
                    }
                        : null,
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
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
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_outlined, size: 60),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrice(
      BuildContext context,
      ProductEntity product,
      ) {
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

  Widget _buildSpecifications(ProductEntity product) {
    if (product.specifications.isEmpty) {
      return const Text('No specifications available.');
    }

    return Column(
      children: product.specifications.entries.map((entry) {
        final label = entry.key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) =>
        word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
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
              Expanded(
                flex: 3,
                child: Text(entry.value.toString()),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
