import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_entity.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';

class ProductPurchaseSection extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductPurchaseSection({super.key, required this.product});

  @override
  ConsumerState<ProductPurchaseSection> createState() =>
      _ProductPurchaseSectionState();
}

class _ProductPurchaseSectionState
    extends ConsumerState<ProductPurchaseSection> {
  int _quantity = 1;
  bool _isAdding = false;

  void _changeQuantity(int value) {
    final stock = widget.product.stockQuantity;

    if (value < 1 || value > stock) return;

    setState(() {
      _quantity = value;
    });
  }

  Future<void> _addToCart() async {
    if (widget.product.stockQuantity <= 0) return;

    setState(() => _isAdding = true);

    try {
      await ref
          .read(cartViewModelProvider.notifier)
          .addToCart(productId: widget.product.id, quantity: _quantity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_quantity item(s) added to cart'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.push('/cart');
            },
          ),
        ),
      );

      setState(() => _quantity = 1);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add product: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stockQuantity <= 0;
    final totalPrice = product.price * _quantity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOutOfStock) ...[
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.outlined(
                onPressed: _quantity > 1
                    ? () => _changeQuantity(_quantity - 1)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.outlined(
                onPressed: _quantity < product.stockQuantity
                    ? () => _changeQuantity(_quantity + 1)
                    : null,
                icon: const Icon(Icons.add),
              ),
              const Spacer(),
              Text(
                'Total: ₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isOutOfStock || _isAdding ? null : _addToCart,
            icon: _isAdding
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.shopping_cart_outlined),
            label: Text(
              isOutOfStock
                  ? 'Out of Stock'
                  : _isAdding
                  ? 'Adding...'
                  : 'Add to Cart',
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isOutOfStock || _isAdding ? null : _buyNow,
            icon: const Icon(Icons.flash_on),
            label: const Text('Buy Now'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _buyNow() async {
    if (widget.product.stockQuantity <= 0) return;

    setState(() => _isAdding = true);

    try {
      await ref
          .read(cartViewModelProvider.notifier)
          .addToCart(productId: widget.product.id, quantity: _quantity);

      if (!mounted) return;

      context.push('/checkout');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to proceed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }
}
