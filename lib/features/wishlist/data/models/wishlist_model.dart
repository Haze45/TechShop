import '../../domain/entities/wishlist_entity.dart';
import 'wishlist_item_model.dart';

class WishlistModel extends WishlistEntity {
  const WishlistModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      items: (json['wishlist_items'] as List<dynamic>? ?? [])
          .map(
            (item) => WishlistItemModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}