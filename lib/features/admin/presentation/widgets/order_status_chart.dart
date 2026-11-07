import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_status_count.dart';
import 'admin_empty_state.dart';

class OrderStatusChart extends StatelessWidget {
  final List<OrderStatusCount> data;

  const OrderStatusChart({super.key, required this.data});

  static const Map<String, Color> statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'processing': Colors.purple,
    'shipped': Colors.indigo,
    'delivered': Colors.green,
    'cancelled': Colors.red,
  };

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalOrders = data.fold<int>(
      0,
      (total, item) => total + item.orderCount,
    );

    final chartData = data.where((item) => item.orderCount > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Distribution of all orders',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            if (totalOrders == 0)
              const AdminEmptyState(
                title: 'No Orders Available',
                message: 'Order statistics will appear here when customers place orders.',
                icon: Icons.shopping_bag_outlined,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 450;

                  final chart = SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 55,
                        sectionsSpace: 3,
                        sections: chartData.map((item) {
                          final color =
                              statusColors[item.status] ?? Colors.grey;

                          return PieChartSectionData(
                            value: item.orderCount.toDouble(),
                            color: color,
                            radius: 35,
                            showTitle: false,
                          );
                        }).toList(),
                      ),
                    ),
                  );

                  final legend = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((item) {
                      final color = statusColors[item.status] ?? Colors.grey;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                _formatStatus(item.status),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),

                            Text(
                              item.orderCount.toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: chart),
                        const SizedBox(width: 20),
                        Expanded(child: legend),
                      ],
                    );
                  }

                  return Column(
                    children: [chart, const SizedBox(height: 16), legend],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
