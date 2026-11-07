import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/dashboard_date_filter.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/monthly_revenue.dart';
import '../../domain/entities/order_status_count.dart';
import '../../domain/entities/top_customer.dart';
import '../../domain/entities/top_selling_product.dart';
import '../../domain/repositories/admin_analytics_repository.dart';
import '../datasources/admin_analytics_remote_datasource.dart';

class AdminAnalyticsRepositoryImpl implements AdminAnalyticsRepository {
  final AdminAnalyticsRemoteDataSource remoteDataSource;

  AdminAnalyticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<AdminDashboardStats> getDashboardStats({
    required DashboardDateFilter filter,
  }) {
    return remoteDataSource.getDashboardStats(
      filter: filter,
    );
  }

  @override
  Future<List<MonthlyRevenue>> getMonthlyRevenue({
    required DashboardDateFilter filter,
  }) {
    return remoteDataSource.getMonthlyRevenue(
      filter: filter,
    );
  }

  @override
  Future<List<OrderStatusCount>> getOrderStatusStats({
    required DashboardDateFilter filter,
  }) {
    return remoteDataSource.getOrderStatusStats(
      filter: filter,
    );
  }

  @override
  Future<List<TopSellingProduct>> getTopSellingProducts({
    required DashboardDateFilter filter,
  }) {
    return remoteDataSource.getTopSellingProducts(
      filter: filter,
    );
  }

  @override
  Future<List<InventoryAlert>> getInventoryAlerts({int threshold = 10}) {
    return remoteDataSource.getInventoryAlerts(threshold: threshold);
  }

  @override
  Future<List<TopCustomer>> getTopCustomers({
    required DashboardDateFilter filter,
  }) {
    return remoteDataSource.getTopCustomers(
      filter: filter,
    );
  }
}
