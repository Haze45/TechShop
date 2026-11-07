class InventoryAlert {
  final String productId;
  final String productName;
  final String productSku;
  final int stockQuantity;
  final double price;
  final String inventoryStatus;

  const InventoryAlert({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.stockQuantity,
    required this.price,
    required this.inventoryStatus,
  });

  bool get isOutOfStock => inventoryStatus == 'out_of_stock';

  factory InventoryAlert.fromJson(Map<String, dynamic> json) {
    return InventoryAlert(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      productSku: json['product_sku'] as String? ?? '',
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      inventoryStatus: json['inventory_status'] as String,
    );
  }
}
