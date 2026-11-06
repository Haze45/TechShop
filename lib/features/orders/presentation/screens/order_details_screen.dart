import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/order_status_timeline.dart';

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

          return _buildOrderDetails(context, ref, order);
        },
      ),
    );
  }

  Widget _buildOrderDetails(
    BuildContext context,
    WidgetRef ref,
    OrderEntity order,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orderDetailsProvider(orderId));

        try {
          await ref.read(orderDetailsProvider(orderId).future);
        } catch (error) {
          debugPrint('Unable to refresh order: $error');
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context, order),

            const SizedBox(height: 24),

            _buildOrderStatus(context, order),

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

            _buildPaymentDetails(context, order),

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

  Widget _buildOrderStatus(BuildContext context, OrderEntity order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Tracking',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OrderStatusTimeline(status: order.status),
          ],
        ),
      ),
    );
  }

  // =========================================
  // ORDER ITEM
  // =========================================

  Widget _buildOrderItem(BuildContext context, OrderItemEntity item) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90,
                height: 90,
                color: theme.colorScheme.surfaceContainerHighest,
                child:
                    item.productImageUrl != null &&
                        item.productImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.productImageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 35,
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 35),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'SKU: ${item.productSku}',
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 8),

                  Text('Quantity: ${item.quantity}'),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${item.unitPrice.toStringAsFixed(2)} each',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '₹${item.lineTotal.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
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

    String getValue(String key) {
      return (address[key] ?? '').toString().trim();
    }

    final name = getValue('full_name');
    final phone = getValue('phone');
    final street = getValue('address');
    final landmark = getValue('landmark');
    final city = getValue('city');
    final state = getValue('state');
    final postalCode = getValue('postal_code');

    final location = [
      city,
      state,
      postalCode,
    ].where((value) => value.isNotEmpty).join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name.isEmpty ? 'Customer' : name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (street.isNotEmpty) Text(street),
                      if (landmark.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text('Landmark: $landmark'),
                      ],
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(location),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (phone.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.phone_outlined),
                  const SizedBox(width: 10),
                  Text(phone),
                ],
              ),
            ],
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

  Widget _buildPaymentDetails(BuildContext context, OrderEntity order) {
    final theme = Theme.of(context);
    final paymentStatus = order.paymentStatus.toLowerCase();

    final isPaid = paymentStatus == 'paid';
    final isFailed = paymentStatus == 'failed' || paymentStatus == 'refunded';

    final statusColor = isPaid
        ? Colors.green
        : isFailed
        ? Colors.red
        : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(Icons.payment_outlined),
                const SizedBox(width: 12),
                const Expanded(child: Text('Payment Method')),
                Text(
                  order.paymentMethod?.toUpperCase() ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.verified_outlined),
                const SizedBox(width: 12),
                const Expanded(child: Text('Payment Status')),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _capitalize(paymentStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final status = order.status.toLowerCase();
    final paymentStatus = order.paymentStatus.toLowerCase();
    final paymentMethod = order.paymentMethod?.toLowerCase();

    return (status == 'pending' || status == 'confirmed') &&
        paymentMethod == 'cod' &&
        (paymentStatus == 'pending' || paymentStatus == 'failed');
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
