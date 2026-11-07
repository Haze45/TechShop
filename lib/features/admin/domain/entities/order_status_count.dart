class OrderStatusCount {
  final String status;
  final int orderCount;

  const OrderStatusCount({required this.status, required this.orderCount});

  factory OrderStatusCount.fromJson(Map<String, dynamic> json) {
    return OrderStatusCount(
      status: json['status'] as String,
      orderCount: (json['order_count'] as num).toInt(),
    );
  }
}
