import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/admin_analytics_providers.dart';
import '../widgets/admin_error_card.dart';
import '../widgets/admin_loading_card.dart';
import '../widgets/dashboard_date_filter.dart';
import '../widgets/inventory_alerts.dart';
import '../widgets/monthly_revenue_chart.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/order_status_chart.dart';
import '../widgets/top_customers.dart';
import '../widgets/top_selling_products.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);
    final selectedFilter = ref.watch(dashboardDateFilterProvider);
    Future<void> refreshDashboard() async {
      try {
        await Future.wait([
          ref.refresh(adminDashboardStatsProvider.future),
          ref.refresh(adminMonthlyRevenueProvider.future),
          ref.refresh(adminOrderStatusProvider.future),
          ref.refresh(adminTopSellingProductsProvider.future),
          ref.refresh(adminInventoryAlertsProvider.future),
          ref.refresh(adminTopCustomersProvider.future),
        ]);
      } catch (_) {
        // Individual provider error widgets will display failures.
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AdminErrorCard(
              message: 'Unable to load dashboard statistics.',
              onRetry: () {
                ref.invalidate(adminDashboardStatsProvider);
              },
            ),
          ),
        ),
        data: (stats) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 550
                  ? 2
                  : 1;

              return RefreshIndicator(
                onRefresh: refreshDashboard,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    DashboardDateFilterWidget(
                      selectedFilter: selectedFilter,
                      onChanged: (filter) {
                        ref.read(dashboardDateFilterProvider.notifier).state =
                            filter;
                      },
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Business Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Monitor your TechShop business performance.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 2.1 : 1.35,
                      children: [
                        AdminStatCard(
                          title: 'Total Products',
                          value: '${stats.totalProducts}',
                          subtitle: '${stats.activeProducts} active products',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.blue,
                        ),
                        AdminStatCard(
                          title: 'Total Orders',
                          value: '${stats.totalOrders}',
                          subtitle: '${stats.pendingOrders} pending orders',
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.orange,
                        ),
                        AdminStatCard(
                          title: 'Customers',
                          value: '${stats.registeredCustomers}',
                          subtitle: 'Registered customers',
                          icon: Icons.people_outline,
                          color: Colors.green,
                        ),
                        AdminStatCard(
                          title: 'Total Revenue',
                          value: '₹${stats.totalRevenue.toStringAsFixed(2)}',
                          subtitle: '${stats.paidOrders} paid orders',
                          icon: Icons.currency_rupee,
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Monthly Revenue Chart
                    Consumer(
                      builder: (context, ref, child) {
                        final revenueAsync = ref.watch(
                          adminMonthlyRevenueProvider,
                        );

                        return revenueAsync.when(
                          loading: () => const AdminLoadingCard(height: 300),

                          error: (error, stackTrace) => AdminErrorCard(
                            message: 'Unable to load revenue analytics.',
                            onRetry: () {
                              ref.invalidate(adminMonthlyRevenueProvider);
                            },
                          ),

                          data: (revenue) {
                            return MonthlyRevenueChart(data: revenue);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final orderStatusAsync = ref.watch(
                          adminOrderStatusProvider,
                        );

                        return orderStatusAsync.when(
                          loading: () => const AdminLoadingCard(height: 250),

                          error: (error, stackTrace) => AdminErrorCard(
                            message: 'Unable to load order analytics.',
                            onRetry: () {
                              ref.invalidate(adminOrderStatusProvider);
                            },
                          ),

                          data: (orderStatus) {
                            return OrderStatusChart(data: orderStatus);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final topProductsAsync = ref.watch(
                          adminTopSellingProductsProvider,
                        );

                        return topProductsAsync.when(
                          loading: () => const AdminLoadingCard(height: 200),

                          error: (error, stackTrace) => AdminErrorCard(
                            message: 'Unable to load top-selling products.',
                            onRetry: () {
                              ref.invalidate(adminTopSellingProductsProvider);
                            },
                          ),

                          data: (products) {
                            return TopSellingProducts(products: products);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final inventoryAsync = ref.watch(
                          adminInventoryAlertsProvider,
                        );

                        return inventoryAsync.when(
                          loading: () => const AdminLoadingCard(height: 180),

                          error: (error, stackTrace) => AdminErrorCard(
                            message: 'Unable to load inventory alerts.',
                            onRetry: () {
                              ref.invalidate(adminInventoryAlertsProvider);
                            },
                          ),

                          data: (alerts) {
                            return InventoryAlerts(alerts: alerts);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Consumer(
                      builder: (context, ref, child) {
                        final customersAsync = ref.watch(
                          adminTopCustomersProvider,
                        );

                        return customersAsync.when(
                          loading: () => const AdminLoadingCard(height: 150),

                          error: (error, stackTrace) => AdminErrorCard(
                            message: 'Unable to load customer analytics.',
                            onRetry: () {
                              ref.invalidate(adminTopCustomersProvider);
                            },
                          ),

                          data: (customers) {
                            return TopCustomers(customers: customers);
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Inventory Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: columns == 1 ? 2.1 : 1.35,
                      children: [
                        AdminStatCard(
                          title: 'Active Products',
                          value: '${stats.activeProducts}',
                          subtitle: 'Visible to customers',
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        AdminStatCard(
                          title: 'Out of Stock',
                          value: '${stats.outOfStockProducts}',
                          subtitle: 'Require restocking',
                          icon: Icons.warning_amber_outlined,
                          color: Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Order Overview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: [
                        AdminStatCard(
                          title: 'Pending Orders',
                          value: stats.pendingOrders.toString(),
                          subtitle: 'Awaiting processing',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                        ),
                        AdminStatCard(
                          title: 'Delivered Orders',
                          value: stats.deliveredOrders.toString(),
                          subtitle: 'Successfully delivered',
                          icon: Icons.local_shipping,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Inventory Management'),
                        subtitle: const Text(
                          'Manage stock and view inventory levels',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.push('/admin/inventory');
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Review Management Navigation
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.rate_review_outlined),
                        title: const Text('Manage Reviews'),
                        subtitle: const Text(
                          'Approve or reject customer reviews',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.go('/admin/reviews');
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Customer Support Navigation
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.support_agent),
                        title: const Text('Customer Support'),
                        subtitle: const Text('Manage customer support tickets'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          context.push('/admin/support');
                        },
                      ),
                    ),

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
