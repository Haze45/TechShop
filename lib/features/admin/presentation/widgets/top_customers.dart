import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/top_customer.dart';
import 'admin_empty_state.dart';

class TopCustomers extends StatelessWidget {
  final List<TopCustomer> customers;

  const TopCustomers({super.key, required this.customers});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No order date';

    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Customers',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Customers ranked by paid spending',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            if (customers.isEmpty)
              const AdminEmptyState(
                title: 'No Customer Activity',
                message: 'Customer statistics will appear here when orders are placed.',
                icon: Icons.people_outline,
              )
            else
              ...List.generate(customers.length, (index) {
                final customer = customers[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer ranking
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Customer information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            if (customer.phone != null &&
                                customer.phone!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                customer.phone!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],

                            const SizedBox(height: 5),

                            Text(
                              '${customer.totalOrders} orders',
                              style: theme.textTheme.bodySmall,
                            ),

                            const SizedBox(height: 3),

                            Text(
                              'Last order: ${_formatDate(customer.lastOrderAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Total spending
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(customer.totalSpent),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text('Total spent', style: theme.textTheme.bodySmall),
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
