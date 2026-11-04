import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order_entity.dart';
import '../viewmodels/order_state.dart';
import '../viewmodels/order_viewmodel.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  String _selectedStatus = 'all';
  String _selectedSort = 'newest';

  final List<Map<String, String>> _statusFilters = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Confirmed', 'value': 'confirmed'},
    {'label': 'Processing', 'value': 'processing'},
    {'label': 'Shipped', 'value': 'shipped'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(),
        data: (orderState) {
          if (orderState.isEmpty) {
            return _buildEmptyOrders(context);
          }

          return _buildOrderList(context, orderState);
        },
      ),
    );
  }

  // =========================================
  // ERROR STATE
  // =========================================

  Widget _buildErrorState() {
    return Center(
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
    );
  }

  // =========================================
  // FILTER AND SORT ORDERS
  // =========================================

  List<OrderEntity> _getFilteredOrders(List<OrderEntity> orders) {
    final filteredOrders = orders.where((order) {
      if (_selectedStatus == 'all') return true;

      return order.status.toLowerCase() == _selectedStatus;
    }).toList();

    switch (_selectedSort) {
      case 'oldest':
        filteredOrders.sort((a, b) => a.placedAt.compareTo(b.placedAt));
        break;

      case 'highest':
        filteredOrders.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;

      case 'lowest':
        filteredOrders.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;

      case 'newest':
      default:
        filteredOrders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
        break;
    }

    return filteredOrders;
  }

  // =========================================
  // ORDER LIST
  // =========================================

  Widget _buildOrderList(BuildContext context, OrderState orderState) {
    final filteredOrders = _getFilteredOrders(orderState.orders);

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(orderViewModelProvider.notifier).refreshOrders();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildOrderSummary(context, orderState),

          const SizedBox(height: 24),

          Text(
            'Filter Orders',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildStatusFilters(),

          const SizedBox(height: 24),

          _buildSortingSection(context),

          const SizedBox(height: 12),

          if (filteredOrders.isEmpty)
            _buildNoFilteredOrders(context)
          else
            ...filteredOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildOrderCard(context, order),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================
  // ORDER SUMMARY
  // =========================================

  Widget _buildOrderSummary(BuildContext context, OrderState orderState) {
    final theme = Theme.of(context);

    final deliveredCount = orderState.orders
        .where((order) => order.status.toLowerCase() == 'delivered')
        .length;

    final activeCount = orderState.orders.where((order) {
      final status = order.status.toLowerCase();

      return status != 'delivered' && status != 'cancelled';
    }).length;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Shopping Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.receipt_long_outlined,
                    'Total Orders',
                    orderState.totalOrders.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.local_shipping_outlined,
                    'Active',
                    activeCount.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    Icons.check_circle_outline,
                    'Delivered',
                    deliveredCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 25),

        const SizedBox(height: 8),

        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  // =========================================
  // STATUS FILTERS
  // =========================================

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusFilters.map((filter) {
        final isSelected = _selectedStatus == filter['value'];

        return ChoiceChip(
          label: Text(filter['label']!),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedStatus = filter['value']!;
            });
          },
        );
      }).toList(),
    );
  }

  // =========================================
  // SORTING SECTION
  // =========================================

  Widget _buildSortingSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Recent Orders',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(width: 8),

        DropdownButton<String>(
          value: _selectedSort,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
            DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
            DropdownMenuItem(
              value: 'highest',
              child: Text('Price: High to Low'),
            ),
            DropdownMenuItem(
              value: 'lowest',
              child: Text('Price: Low to High'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _selectedSort = value;
            });
          },
        ),
      ],
    );
  }

  // =========================================
  // ORDER CARD
  // =========================================

  Widget _buildOrderCard(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Number', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        order.orderNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _buildStatusBadge(order.status),
              ],
            ),

            const Divider(height: 24),

            // Order date and item count
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),

                const SizedBox(width: 8),

                Expanded(child: Text(_formatDate(order.placedAt))),

                const Icon(Icons.shopping_bag_outlined, size: 17),

                const SizedBox(width: 6),

                Text(
                  '${order.totalItems} '
                  '${order.totalItems == 1 ? 'item' : 'items'}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Product image previews
            _buildProductPreviews(context, order),

            const SizedBox(height: 16),

            // Payment information
            Row(
              children: [
                const Icon(Icons.payment_outlined, size: 18),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    order.paymentMethod?.toUpperCase() ?? 'N/A',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

                _buildPaymentBadge(order.paymentStatus),
              ],
            ),

            const Divider(height: 24),

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
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // View details button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/order/${order.id}');
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Order Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // PRODUCT IMAGE PREVIEWS
  // =========================================

  Widget _buildProductPreviews(BuildContext context, OrderEntity order) {
    final items = order.items.take(3).toList();
    final remainingItems = order.items.length - items.length;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 58,
                height: 58,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child:
                    item.productImageUrl != null &&
                        item.productImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.productImageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      )
                    : const Icon(Icons.image_outlined),
              ),
            ),
          );
        }),

        if (remainingItems > 0)
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$remainingItems',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  // =========================================
  // ORDER STATUS BADGE
  // =========================================

  Widget _buildStatusBadge(String status) {
    final normalizedStatus = status.toLowerCase();

    Color backgroundColor;
    Color textColor;

    switch (normalizedStatus) {
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
        normalizedStatus.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================
  // PAYMENT STATUS BADGE
  // =========================================

  Widget _buildPaymentBadge(String status) {
    final normalizedStatus = status.toLowerCase();

    final isPaid = normalizedStatus == 'paid';

    final isFailed =
        normalizedStatus == 'failed' || normalizedStatus == 'refunded';

    final backgroundColor = isPaid
        ? Colors.green.shade100
        : isFailed
        ? Colors.red.shade100
        : Colors.orange.shade100;

    final textColor = isPaid
        ? Colors.green.shade800
        : isFailed
        ? Colors.red.shade800
        : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        normalizedStatus.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================
  // NO FILTERED ORDERS
  // =========================================

  Widget _buildNoFilteredOrders(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No orders found for this filter.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedStatus = 'all';
              });
            },
            child: const Text('Show All Orders'),
          ),
        ],
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
