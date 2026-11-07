import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/dashboard_date_filter.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/monthly_revenue.dart';
import '../../domain/entities/order_status_count.dart';
import '../../domain/entities/top_customer.dart';
import '../../domain/entities/top_selling_product.dart';

class AdminAnalyticsRemoteDataSource {
  final SupabaseClient supabase;

  AdminAnalyticsRemoteDataSource(this.supabase);

  Future<AdminDashboardStats> getDashboardStats({
    required DashboardDateFilter filter,
  }) async {
    final response = await supabase.rpc(
      'get_admin_dashboard_stats',
      params: {'p_start_at': filter.startAtUtc, 'p_end_at': filter.endAtUtc},
    );

    return AdminDashboardStats.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<MonthlyRevenue>> getMonthlyRevenue({
    required DashboardDateFilter filter,
  }) async {
    final response = await supabase.rpc(
      'get_admin_monthly_revenue',
      params: {
        'p_start_at': filter.startAtUtc,
        'p_end_at': filter.endAtUtc,
      },
    );

    return (response as List).map((item) {
      return MonthlyRevenue.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<List<OrderStatusCount>> getOrderStatusStats({
    required DashboardDateFilter filter,
  }) async {
    final response = await supabase.rpc(
      'get_admin_order_status_stats',
      params: {
        'p_start_at': filter.startAtUtc,
        'p_end_at': filter.endAtUtc,
      },
    );

    return (response as List).map((item) {
      return OrderStatusCount.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<List<TopSellingProduct>> getTopSellingProducts({
    required DashboardDateFilter filter,
  }) async {
    final response = await supabase.rpc(
      'get_admin_top_selling_products',
      params: {
        'p_start_at': filter.startAtUtc,
        'p_end_at': filter.endAtUtc,
      },
    );

    return (response as List).map((item) {
      return TopSellingProduct.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<List<InventoryAlert>> getInventoryAlerts({int threshold = 10}) async {
    final response = await supabase.rpc(
      'get_admin_inventory_alerts',
      params: {'p_threshold': threshold},
    );

    return (response as List).map((item) {
      return InventoryAlert.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<List<TopCustomer>> getTopCustomers({
    required DashboardDateFilter filter,
  }) async {
    final response = await supabase.rpc(
      'get_admin_top_customers',
      params: {
        'p_start_at': filter.startAtUtc,
        'p_end_at': filter.endAtUtc,
      },
    );

    return (response as List).map((item) {
      return TopCustomer.fromJson(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }
}
