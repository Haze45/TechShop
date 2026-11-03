import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    super.productId,
    required super.productName,
    required super.productSku,
    super.productImageUrl,
    required super.unitPrice,
    required super.quantity,
    required super.lineTotal,
    required super.createdAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      productId: json['product_id']?.toString(),
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String,
      productImageUrl: json['product_image_url'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: (json['line_total'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_image_url': productImageUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
      'line_total': lineTotal,
      'created_at': createdAt.toIso8601String(),
    };
  }
}