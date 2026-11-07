class MonthlyRevenue {
  final DateTime monthStart;
  final double revenue;
  final int orderCount;

  const MonthlyRevenue({
    required this.monthStart,
    required this.revenue,
    required this.orderCount,
  });

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      monthStart: DateTime.parse(json['month_start'].toString()),
      revenue: (json['revenue'] as num).toDouble(),
      orderCount: (json['order_count'] as num).toInt(),
    );
  }
}
