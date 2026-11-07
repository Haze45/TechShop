import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/domain/entities/order_entity.dart';
import '../providers/admin_order_providers.dart';

class AdminOrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(adminOrderByIdProvider(orderId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('Unable to load order details'),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(adminOrderByIdProvider(orderId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (order) => _buildOrderDetails(context, ref, order),
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOrderHeader(context, order),
        const SizedBox(height: 16),
        _buildOrderStatusActions(context, ref, order),
        const SizedBox(height: 16),
        _buildOrderCancellation(context, ref, order),
        const SizedBox(height: 16),
        _buildCustomerDetails(context, order),
        const SizedBox(height: 16),
        _buildOrderedProducts(context, order),
        const SizedBox(height: 16),
        _buildPaymentDetails(context, order),
        const SizedBox(height: 16),
        _buildPriceSummary(context, order),
      ],
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.orderNumber,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Placed: ${_formatDate(order.placedAt)}'),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip('Order', order.status),
                _buildStatusChip('Payment', order.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context, OrderEntity order) {
    final address = order.shippingAddress;

    final name = address['full_name']?.toString() ?? 'N/A';
    final phone = address['phone']?.toString() ?? 'N/A';
    final street = address['address']?.toString() ?? '';
    final landmark = address['landmark']?.toString() ?? '';
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final postalCode = address['postal_code']?.toString() ?? '';
    final country = address['country']?.toString() ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer & Delivery Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person_outline, 'Customer', name),
            _infoRow(Icons.phone_outlined, 'Phone', phone),
            if (street.isNotEmpty)
              _infoRow(Icons.home_outlined, 'Address', street),
            if (landmark.isNotEmpty)
              _infoRow(Icons.place_outlined, 'Landmark', landmark),
            _infoRow(
              Icons.location_on_outlined,
              'Location',
              [
                city,
                state,
                postalCode,
                country,
              ].where((value) => value.isNotEmpty).join(', '),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedProducts(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordered Products (${order.items.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (order.items.isEmpty)
              const Text('No product information available.')
            else
              ...order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            item.productImageUrl != null &&
                                item.productImageUrl!.isNotEmpty
                            ? Image.network(
                                item.productImageUrl!,
                                width: 65,
                                height: 65,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('SKU: ${item.productSku}'),
                            Text(
                              '${item.quantity} × ${_currency(item.unitPrice)}',
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currency(item.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow(
              Icons.payment,
              'Payment Method',
              order.paymentMethod?.toUpperCase() ?? 'N/A',
            ),
            _infoRow(
              Icons.receipt_long,
              'Payment Status',
              order.paymentStatus.toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _priceRow('Subtotal', order.subtotal),
            _priceRow('Shipping Fee', order.shippingFee),
            _priceRow('Tax', order.tax),
            _priceRow('Discount', -order.discount),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currency(order.totalAmount),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(_currency(amount))],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final color = _statusColor(status);

    return Chip(
      label: Text(
        '$label: ${status.toUpperCase()}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.10),
      side: BorderSide.none,
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'failed':
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

  Widget _imagePlaceholder() {
    return Container(
      width: 65,
      height: 65,
      color: Colors.grey.withValues(alpha: 0.15),
      child: const Icon(Icons.image_outlined),
    );
  }

  String _currency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  Widget _buildOrderStatusActions(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    final nextStatus = switch (order.status.toLowerCase()) {
      'pending' => 'confirmed',
      'confirmed' => 'processing',
      'processing' => 'shipped',
      'shipped' => 'delivered',
      _ => null,
    };

    final updateState = ref.watch(adminOrderStatusUpdateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Order Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (nextStatus == null)
              const Text('No further status updates are available.')
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: updateState.isLoading
                      ? null
                      : () => _updateOrderStatus(
                          context,
                          ref,
                          order.id,
                          nextStatus,
                        ),
                  icon: updateState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.local_shipping_outlined),
                  label: Text(
                    updateState.isLoading
                        ? 'Updating...'
                        : 'Mark as ${_capitalize(nextStatus)}',
                  ),
                ),
              ),

            if (updateState.hasError) ...[
              const SizedBox(height: 8),
              Text(
                updateState.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    WidgetRef ref,
    String orderId,
    String newStatus,
  ) async {
    await ref
        .read(adminOrderStatusUpdateProvider.notifier)
        .updateStatus(orderId, newStatus);

    if (!context.mounted) return;

    final result = ref.read(adminOrderStatusUpdateProvider);

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.invalidate(adminOrderByIdProvider(orderId));
    ref.invalidate(adminOrdersProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order status updated to ${_capitalize(newStatus)}.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _capitalize(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }

  Widget _buildOrderCancellation(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    final status = order.status.toLowerCase();
    final paymentStatus = order.paymentStatus.toLowerCase();

    final canCancel =
        (status == 'pending' || status == 'confirmed') &&
        paymentStatus != 'paid';

    final cancellationState = ref.watch(adminOrderCancellationProvider);

    if (!canCancel) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancel Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cancelling this order will restore its product stock. '
              'Paid orders require a separate refund process.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: cancellationState.isLoading
                    ? null
                    : () => _confirmOrderCancellation(context, ref, order),
                icon: cancellationState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cancel_outlined),
                label: Text(
                  cancellationState.isLoading
                      ? 'Cancelling...'
                      : 'Cancel Order',
                ),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
            if (cancellationState.hasError) ...[
              const SizedBox(height: 8),
              Text(
                cancellationState.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrderCancellation(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text(
            'Are you sure you want to cancel this order? '
            'The product stock quantities will be restored.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Order'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirm Cancellation'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await ref
        .read(adminOrderCancellationProvider.notifier)
        .cancelOrder(order.id);

    if (!context.mounted) return;

    final result = ref.read(adminOrderCancellationProvider);

    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancellation failed: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.invalidate(adminOrderByIdProvider(order.id));
    ref.invalidate(adminOrdersProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order cancelled and product stock restored.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
