class OrderItemEntity {
  final String id;
  final String orderId;
  final String? productId;

  final String productName;
  final String productSku;
  final String? productImageUrl;

  final double unitPrice;
  final int quantity;
  final double lineTotal;

  final DateTime createdAt;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.productSku,
    this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.createdAt,
  });
}
