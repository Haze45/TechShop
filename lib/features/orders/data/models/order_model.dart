import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.userId,
    required super.status,
    required super.paymentStatus,
    super.paymentMethod,
    required super.subtotal,
    required super.shippingFee,
    required super.tax,
    required super.discount,
    required super.totalAmount,
    required super.shippingAddress,
    super.notes,
    required super.placedAt,
    required super.createdAt,
    required super.updatedAt,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderItems = json['order_items'] as List? ?? [];

    return OrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'] as String,
      userId: json['user_id'].toString(),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: Map<String, dynamic>.from(
        json['shipping_address'] as Map,
      ),
      notes: json['notes'] as String?,
      placedAt: DateTime.parse(json['placed_at'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      items: orderItems
          .map(
            (item) =>
                OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'tax': tax,
      'discount': discount,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'notes': notes,
      'placed_at': placedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
