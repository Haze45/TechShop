import 'wishlist_item_entity.dart';

class WishlistEntity {
  final String id;
  final String userId;
  final List<WishlistItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WishlistEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  // Total number of saved products.
  int get totalItems => items.length;

  // Check whether wishlist is empty.
  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  // Check whether a product is already in wishlist.
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }
}
