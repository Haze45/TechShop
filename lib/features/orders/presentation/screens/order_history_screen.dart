import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/order_state.dart';
import '../viewmodels/order_viewmodel.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 12),
              const Text('Unable to load orders'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(orderViewModelProvider);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (orderState) {
          if (orderState.isEmpty) {
            return _buildEmptyOrders(context);
          }

          return _buildOrderList(context, ref, orderState);
        },
      ),
    );
  }

  // =========================================
  // ORDER LIST
  // =========================================

  Widget _buildOrderList(
    BuildContext context,
    WidgetRef ref,
    OrderState orderState,
  ) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.read(orderViewModelProvider.notifier).refreshOrders();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orderState.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orderState.orders[index];

          return Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order number and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(order.status),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Order date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(order.placedAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Number of items
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text('${order.totalItems} items'),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Total amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // View details button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/order/${order.id}');
                      },
                      child: const Text('View Order Details'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================
  // ORDER STATUS BADGE
  // =========================================

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'confirmed':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;

      case 'processing':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;

      case 'shipped':
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        break;

      case 'delivered':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;

      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;

      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================
  // EMPTY ORDERS
  // =========================================

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 85,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No Orders Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your orders will appear here once you make a purchase.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // FORMAT DATE
  // =========================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day/$month/$year';
  }
}
