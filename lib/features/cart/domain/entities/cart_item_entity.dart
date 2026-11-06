import '../../../products/domain/entities/product_entity.dart';

class CartItemEntity {
  final String id;
  final String cartId;
  final String productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProductEntity product;

  const CartItemEntity({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  double get subtotal => product.price * quantity;

  bool get isInStock => product.stockQuantity >= quantity;

  bool get canIncreaseQuantity => quantity < product.stockQuantity;
}
