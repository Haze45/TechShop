import 'cart_item_entity.dart';

class CartEntity {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  // Total number of individual products.
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  // Total cart price.
  double get totalPrice {
    return items.fold(0, (total, item) => total + item.subtotal);
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
