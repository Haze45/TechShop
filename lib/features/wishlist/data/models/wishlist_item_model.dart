import '../../domain/entities/wishlist_item_entity.dart';
import '../../../products/data/models/product_model.dart';

class WishlistItemModel extends WishlistItemEntity {
  const WishlistItemModel({
    required super.id,
    required super.wishlistId,
    required super.productId,
    required super.createdAt,
    required super.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'].toString(),
      wishlistId: json['wishlist_id'].toString(),
      productId: json['product_id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      product: ProductModel.fromJson(json['products'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wishlist_id': wishlistId,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
