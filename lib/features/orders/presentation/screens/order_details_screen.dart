import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order_entity.dart';
import '../viewmodels/order_viewmodel.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderFuture = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        actions: [
          IconButton(
            tooltip: 'Refresh Order Status',
            onPressed: () {
              ref.invalidate(orderDetailsProvider(orderId));
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: orderFuture.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load order: $error')),
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found.'));
          }

          return _buildOrderDetails(context,ref, order);
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context,WidgetRef ref, OrderEntity order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(context, order),

          const SizedBox(height: 24),

          _buildOrderStatus(order),

          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Ordered Products'),

          const SizedBox(height: 12),

          ...order.items.map((item) => _buildOrderItem(context, item)),

          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Delivery Address'),

          const SizedBox(height: 12),

          _buildShippingAddress(order),

          const SizedBox(height: 24),

          _buildSectionTitle(context, 'Price Details'),

          const SizedBox(height: 12),

          _buildPriceDetails(context, order),

          const SizedBox(height: 24),

          _buildPaymentDetails(order),

          // Cancel Order Button
          if (_canCancelOrder(order)) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmCancellation(
                    context,
                    // Pass WidgetRef from build method (see below).
                    ref,
                    order.id,
                  );
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Order'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================
  // ORDER HEADER
  // =========================================

  Widget _buildOrderHeader(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Number', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            SelectableText(
              order.orderNumber,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Placed on: ${_formatDate(order.placedAt)}'),
            const SizedBox(height: 6),
            Text('Total Items: ${order.totalItems}'),
          ],
        ),
      ),
    );
  }

  // =========================================
  // ORDER STATUS
  // =========================================

  Widget _buildOrderStatus(OrderEntity order) {
    const steps = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
    ];

    final currentIndex = steps.indexOf(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (order.isCancelled) ...[
              const Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 25),
                  SizedBox(width: 10),
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else if (currentIndex == -1) ...[
              Text('Unknown order status: ${order.status}'),
            ] else ...[
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;

                final isCompleted = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : Colors.grey,
                            size: 24,
                          ),
                          if (index != steps.length - 1)
                            Container(
                              width: 2,
                              height: 25,
                              color: isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                        ],
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capitalize(step),
                                style: TextStyle(
                                  fontWeight: isCurrent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCompleted
                                      ? Colors.green.shade800
                                      : Colors.grey,
                                ),
                              ),

                              if (isCurrent)
                                const Text(
                                  'Current Order Status',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================
  // ORDER ITEM
  // =========================================

  Widget _buildOrderItem(BuildContext context, dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 85,
                height: 85,
                child:
                    item.productImageUrl != null &&
                        item.productImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.productImageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.image_not_supported_outlined),
                      )
                    : const Icon(Icons.image_outlined, size: 35),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('SKU: ${item.productSku}'),
                  Text('Quantity: ${item.quantity}'),
                  const SizedBox(height: 6),
                  Text(
                    '₹${item.unitPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Subtotal: ₹${item.lineTotal.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // SHIPPING ADDRESS
  // =========================================

  Widget _buildShippingAddress(OrderEntity order) {
    final address = order.shippingAddress;

    final name = address['full_name'] ?? '';
    final phone = address['phone'] ?? '';
    final street = address['address'] ?? '';
    final landmark = address['landmark'] ?? '';
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final postalCode = address['postal_code'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(street.toString()),
            if (landmark.toString().isNotEmpty) Text('Landmark: $landmark'),
            Text('$city, $state - $postalCode'),
            const SizedBox(height: 8),
            Text('Phone: $phone'),
          ],
        ),
      ),
    );
  }

  // =========================================
  // PRICE DETAILS
  // =========================================

  Widget _buildPriceDetails(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _priceRow('Subtotal', order.subtotal),
            const SizedBox(height: 10),
            _priceRow('Shipping', order.shippingFee),
            const SizedBox(height: 10),
            _priceRow('Tax', order.tax),
            const SizedBox(height: 10),
            _priceRow('Discount', -order.discount),
            const Divider(height: 24),
            _priceRow('Total Amount', order.totalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  // =========================================
  // PAYMENT DETAILS
  // =========================================

  Widget _buildPaymentDetails(OrderEntity order) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payment),
        title: Text(
          'Payment Method: ${order.paymentMethod?.toUpperCase() ?? 'N/A'}',
        ),
        subtitle: Text('Payment Status: ${_capitalize(order.paymentStatus)}'),
      ),
    );
  }

  // =========================================
  // COMMON HELPERS
  // =========================================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  bool _canCancelOrder(OrderEntity order) {
    return (order.status == 'pending' || order.status == 'confirmed') &&
        order.paymentMethod == 'cod' &&
        (order.paymentStatus == 'pending' || order.paymentStatus == 'failed');
  }

  Future<void> _confirmCancellation(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Order?'),
          content: const Text(
            'Are you sure you want to cancel this order? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep Order'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !context.mounted) return;

    try {
      await ref.read(orderViewModelProvider.notifier).cancelOrder(orderId);

      if (!context.mounted) return;

      ref.invalidate(orderDetailsProvider(orderId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to cancel order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
