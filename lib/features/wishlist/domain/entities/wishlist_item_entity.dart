import '../../../products/domain/entities/product_entity.dart';

class WishlistItemEntity {
  final String id;
  final String wishlistId;
  final String productId;
  final DateTime createdAt;
  final ProductEntity product;

  const WishlistItemEntity({
    required this.id,
    required this.wishlistId,
    required this.productId,
    required this.createdAt,
    required this.product,
  });
}