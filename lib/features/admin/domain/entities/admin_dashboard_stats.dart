class AdminDashboardStats {
  final int totalProducts;
  final int activeProducts;
  final int inactiveProducts;
  final int outOfStockProducts;

  final int totalOrders;
  final int pendingOrders;
  final int deliveredOrders;
  final int paidOrders;

  final double totalRevenue;
  final int registeredCustomers;

  const AdminDashboardStats({
    required this.totalProducts,
    required this.activeProducts,
    required this.inactiveProducts,
    required this.outOfStockProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.deliveredOrders,
    required this.paidOrders,
    required this.totalRevenue,
    required this.registeredCustomers,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalProducts: (json['total_products'] as num).toInt(),
      activeProducts: (json['active_products'] as num).toInt(),
      inactiveProducts: (json['inactive_products'] as num).toInt(),
      outOfStockProducts: (json['out_of_stock_products'] as num).toInt(),
      totalOrders: (json['total_orders'] as num).toInt(),
      pendingOrders: (json['pending_orders'] as num).toInt(),
      deliveredOrders: (json['delivered_orders'] as num).toInt(),
      paidOrders: (json['paid_orders'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      registeredCustomers: (json['registered_customers'] as num).toInt(),
    );
  }
}
