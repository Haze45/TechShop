import 'package:flutter/material.dart';

class OrderStatusTimeline extends StatelessWidget {
  final String status;

  const OrderStatusTimeline({super.key, required this.status});

  static const List<String> _statuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
  ];

  static const List<String> _labels = [
    'Order Placed',
    'Order Confirmed',
    'Processing',
    'Shipped',
    'Delivered',
  ];

  int get _currentIndex => _statuses.indexOf(status.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status.toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_currentIndex == -1) {
      return const Text('Order status is unavailable.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_statuses.length, (index) {
        final isCompleted = index <= _currentIndex;
        final isLast = index == _statuses.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: isCompleted
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall,
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index < _currentIndex
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 28),
                child: Text(
                  _labels[index],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCompleted
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isCompleted
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
