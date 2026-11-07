import 'package:flutter/material.dart';

import '../../../orders/domain/entities/order_entity.dart';

class AdminOrderStatistics extends StatelessWidget {
  final List<OrderEntity> orders;

  const AdminOrderStatistics({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final totalOrders = orders.length;

    final pendingOrders = orders
        .where((order) => order.status.toLowerCase() == 'pending')
        .length;

    final deliveredOrders = orders
        .where((order) => order.status.toLowerCase() == 'delivered')
        .length;

    final cancelledOrders = orders
        .where((order) => order.status.toLowerCase() == 'cancelled')
        .length;

    final paidRevenue = orders
        .where((order) => order.paymentStatus.toLowerCase() == 'paid')
        .fold<double>(0, (total, order) => total + order.totalAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 600 ? 4 : 2;
            final spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _StatCard(
                    title: 'Total Orders',
                    value: '$totalOrders',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _StatCard(
                    title: 'Pending',
                    value: '$pendingOrders',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _StatCard(
                    title: 'Delivered',
                    value: '$deliveredOrders',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _StatCard(
                    title: 'Cancelled',
                    value: '$cancelledOrders',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 12),

        _StatCard(
          title: 'Paid Revenue',
          value: '₹${paidRevenue.toStringAsFixed(2)}',
          icon: Icons.currency_rupee,
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
