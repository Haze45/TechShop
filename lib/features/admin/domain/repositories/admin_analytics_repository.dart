import '../entities/admin_dashboard_stats.dart';
import '../entities/dashboard_date_filter.dart';
import '../entities/inventory_alert.dart';
import '../entities/monthly_revenue.dart';
import '../entities/order_status_count.dart';
import '../entities/top_customer.dart';
import '../entities/top_selling_product.dart';

abstract class AdminAnalyticsRepository {
  Future<AdminDashboardStats> getDashboardStats({
    required DashboardDateFilter filter,
  });

  Future<List<MonthlyRevenue>> getMonthlyRevenue({
    required DashboardDateFilter filter,
  });

  Future<List<OrderStatusCount>> getOrderStatusStats({
    required DashboardDateFilter filter,
  });

  Future<List<TopSellingProduct>> getTopSellingProducts({
    required DashboardDateFilter filter,
  });

  Future<List<TopCustomer>> getTopCustomers({
    required DashboardDateFilter filter,
  });

  Future<List<InventoryAlert>> getInventoryAlerts({int threshold = 10});

}
