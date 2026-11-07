import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/admin_analytics_remote_datasource.dart';
import '../../data/repositories/admin_analytics_repository_impl.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/dashboard_date_filter.dart';
import '../../domain/entities/inventory_alert.dart';
import '../../domain/entities/monthly_revenue.dart';
import '../../domain/entities/order_status_count.dart';
import '../../domain/entities/top_customer.dart';
import '../../domain/entities/top_selling_product.dart';
import '../../domain/repositories/admin_analytics_repository.dart';

final adminAnalyticsRemoteDataSourceProvider =
    Provider<AdminAnalyticsRemoteDataSource>((ref) {
      return AdminAnalyticsRemoteDataSource(Supabase.instance.client);
    });

final adminAnalyticsRepositoryProvider = Provider<AdminAnalyticsRepository>((
  ref,
) {
  return AdminAnalyticsRepositoryImpl(
    ref.watch(adminAnalyticsRemoteDataSourceProvider),
  );
});

final adminDashboardStatsProvider =
FutureProvider<AdminDashboardStats>((ref) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  final selectedFilter = ref.watch(
    dashboardDateFilterProvider,
  );

  return repository.getDashboardStats(
    filter: selectedFilter,
  );
});

final adminMonthlyRevenueProvider =
FutureProvider<List<MonthlyRevenue>>((ref) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  final selectedFilter = ref.watch(
    dashboardDateFilterProvider,
  );

  return repository.getMonthlyRevenue(
    filter: selectedFilter,
  );
});

final adminOrderStatusProvider =
FutureProvider<List<OrderStatusCount>>((ref) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  final selectedFilter = ref.watch(
    dashboardDateFilterProvider,
  );

  return repository.getOrderStatusStats(
    filter: selectedFilter,
  );
});

final adminTopSellingProductsProvider =
FutureProvider<List<TopSellingProduct>>((ref) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  final selectedFilter = ref.watch(
    dashboardDateFilterProvider,
  );

  return repository.getTopSellingProducts(
    filter: selectedFilter,
  );
});

final adminInventoryAlertsProvider = FutureProvider<List<InventoryAlert>>((
  ref,
) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  return repository.getInventoryAlerts(threshold: 10);
});

final adminTopCustomersProvider =
FutureProvider<List<TopCustomer>>((ref) async {
  final repository = ref.watch(adminAnalyticsRepositoryProvider);

  final selectedFilter = ref.watch(
    dashboardDateFilterProvider,
  );

  return repository.getTopCustomers(
    filter: selectedFilter,
  );
});

final dashboardDateFilterProvider = StateProvider<DashboardDateFilter>((ref) {
  return DashboardDateFilter.last30Days;
});
