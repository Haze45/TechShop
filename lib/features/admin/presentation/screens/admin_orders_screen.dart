import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../orders/domain/entities/order_entity.dart';
import '../../data/services/admin_order_export_service.dart';
import '../providers/admin_order_providers.dart';
import '../widgets/admin_order_statistics.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedSort = 'newest';
  String _selectedDateRange = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filteredOrders = orders.where((order) {
      final query = _searchQuery.toLowerCase();

      final customerName =
          order.shippingAddress['full_name']?.toString().toLowerCase() ?? '';

      final phone =
          order.shippingAddress['phone']?.toString().toLowerCase() ?? '';

      final orderNumber = order.orderNumber.toLowerCase();

      final matchesSearch =
          orderNumber.contains(query) ||
          customerName.contains(query) ||
          phone.contains(query);

      final matchesStatus =
          _selectedStatus == 'all' ||
          order.status.toLowerCase() == _selectedStatus;

      final orderDate = order.placedAt.toLocal();
      final orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);

      bool matchesDate = true;

      switch (_selectedDateRange) {
        case 'today':
          matchesDate = orderDay == today;
          break;

        case '7days':
          matchesDate = !orderDay.isBefore(
            today.subtract(const Duration(days: 6)),
          );
          break;

        case '30days':
          matchesDate = !orderDay.isBefore(
            today.subtract(const Duration(days: 29)),
          );
          break;
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    // Sorting
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
    }

    return filteredOrders;
  }

  Future<void> _exportOrders(List<OrderEntity> orders) async {
    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No orders available to export.')),
      );
      return;
    }

    try {
      await AdminOrderExportService().exportOrders(orders);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order export prepared successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search order, customer or phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filter by order status',
              prefixIcon: const Icon(Icons.filter_list),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Orders')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'processing', child: Text('Processing')),
              DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedStatus = value;
              });
            },
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedSort,
            decoration: InputDecoration(
              labelText: 'Sort Orders',
              prefixIcon: const Icon(Icons.sort),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Newest First')),
              DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
              DropdownMenuItem(value: 'highest', child: Text('Highest Amount')),
              DropdownMenuItem(value: 'lowest', child: Text('Lowest Amount')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedSort = value;
              });
            },
          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            initialValue: _selectedDateRange,
            decoration: InputDecoration(
              labelText: 'Filter by Date',
              prefixIcon: const Icon(Icons.calendar_month),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Time')),
              DropdownMenuItem(value: 'today', child: Text('Today')),
              DropdownMenuItem(value: '7days', child: Text('Last 7 Days')),
              DropdownMenuItem(value: '30days', child: Text('Last 30 Days')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedDateRange = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            tooltip: 'Export Orders',
            onPressed: () {
              ordersAsync.when(
                data: (orders) {
                  _exportOrders(orders);
                },
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Orders are still loading.')),
                  );
                },
                error: (error, stackTrace) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unable to load orders: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.download),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminOrdersProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('Unable to load orders'),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(adminOrdersProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          final filteredOrders = _filterOrders(orders);
          if (orders.isEmpty &&
              _searchQuery.isEmpty &&
              _selectedStatus == 'all') {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('No orders found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminOrdersProvider);
              await ref.read(adminOrdersProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AdminOrderStatistics(orders: orders),

                const SizedBox(height: 20),
                _buildSearchAndFilter(),

                if (filteredOrders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 56),
                          SizedBox(height: 12),
                          Text('No matching orders found'),
                        ],
                      ),
                    ),
                  )
                else
                  ...filteredOrders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AdminOrderCard(order: order),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderEntity order;

  const _AdminOrderCard({required this.order});

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'paid':
        return Colors.green;
      case 'cancelled':
      case 'failed':
      case 'rejected':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'confirmed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _statusChip(String label, String value) {
    final color = _statusColor(value);

    return Chip(
      label: Text(
        '$label: ${value.toUpperCase()}',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress;
    final customerName = address['full_name']?.toString() ?? 'Customer';
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final country = address['country']?.toString() ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Placed on ${_formatDate(order.placedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const Divider(height: 24),

            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(customerName)),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      city,
                      state,
                      country,
                    ].where((part) => part.isNotEmpty).join(', '),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 8),
                Text('${order.totalItems} item(s)'),
                const Spacer(),
                Text(
                  order.paymentMethod?.toUpperCase() ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _statusChip('Order', order.status),
                _statusChip('Payment', order.paymentStatus),
              ],
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/admin/orders/${order.id}');
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
