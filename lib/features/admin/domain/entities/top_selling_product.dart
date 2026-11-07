class TopSellingProduct {
  final String? productId;
  final String productName;
  final String productSku;
  final String? productImageUrl;
  final int unitsSold;
  final double revenue;
  final int orderCount;

  const TopSellingProduct({
    this.productId,
    required this.productName,
    required this.productSku,
    this.productImageUrl,
    required this.unitsSold,
    required this.revenue,
    required this.orderCount,
  });

  factory TopSellingProduct.fromJson(Map<String, dynamic> json) {
    return TopSellingProduct(
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String? ?? '',
      productSku: json['product_sku'] as String? ?? '',
      productImageUrl: json['product_image_url'] as String?,
      unitsSold: (json['units_sold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      orderCount: (json['order_count'] as num).toInt(),
    );
  }
}
