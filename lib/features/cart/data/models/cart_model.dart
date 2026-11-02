import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['cart_items'] as List<dynamic>? ?? [];

    return CartModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      items: itemsJson.map((item) {
        return CartItemModel.fromJson(
          item as Map<String, dynamic>,
        );
      }).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}