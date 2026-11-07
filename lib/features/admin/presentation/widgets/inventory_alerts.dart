import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/inventory_alert.dart';

class InventoryAlerts extends StatelessWidget {
  final List<InventoryAlert> alerts;

  const InventoryAlerts({super.key, required this.alerts});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outOfStockCount = alerts.where((item) => item.isOutOfStock).length;

    final lowStockCount = alerts.length - outOfStockCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Alerts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Products that need stock replenishment',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Summary
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    title: 'Total Alerts',
                    count: alerts.length,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    title: 'Out of Stock',
                    count: outOfStockCount,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryItem(
                    title: 'Low Stock',
                    count: lowStockCount,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Divider(),

            if (alerts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 10),
                    const Text('All active products have healthy stock.'),
                  ],
                ),
              )
            else
              ...alerts.map((product) {
                final isOutOfStock = product.isOutOfStock;
                final color = isOutOfStock ? Colors.red : Colors.orange;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isOutOfStock
                              ? Icons.remove_shopping_cart_outlined
                              : Icons.warning_amber_rounded,
                          color: color,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'SKU: ${product.productSku}',
                              style: theme.textTheme.bodySmall,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _formatCurrency(product.price),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.stockQuantity} left',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            isOutOfStock ? 'Out of Stock' : 'Low Stock',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color,
                            ),
                          ),
                        ],
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
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: theme.textTheme.bodySmall, maxLines: 2),
        ],
      ),
    );
  }
}
