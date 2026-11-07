class TopCustomer {
  final String customerId;
  final String fullName;
  final String? phone;
  final int totalOrders;
  final double totalSpent;
  final DateTime? lastOrderAt;

  const TopCustomer({
    required this.customerId,
    required this.fullName,
    this.phone,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderAt,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerId: json['customer_id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown Customer',
      phone: json['phone'] as String?,
      totalOrders: (json['total_orders'] as num).toInt(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      lastOrderAt: json['last_order_at'] == null
          ? null
          : DateTime.parse(json['last_order_at'] as String),
    );
  }
}
