
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stock_movement_providers.dart';
import '../../domain/entities/stock_movement_entity.dart';

class AdminStockHistoryScreen extends ConsumerStatefulWidget {
  final String productId;
  final String productName;

  const AdminStockHistoryScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  ConsumerState<AdminStockHistoryScreen> createState() =>
      _AdminStockHistoryScreenState();
}

class _AdminStockHistoryScreenState
    extends ConsumerState<AdminStockHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedMovement = 'all';
  String _selectedDateRange = 'all';
  String _selectedSort = 'newest';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // FILTER AND SORT MOVEMENTS
  // --------------------------------------------------

  List<StockMovementEntity> _filterMovements(
      List<StockMovementEntity> movements,
      ) {
    final now = DateTime.now();

    final filtered = movements.where((movement) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch = query.isEmpty ||
          movement.changeType.toLowerCase().contains(query) ||
          _movementLabel(movement.changeType)
              .toLowerCase()
              .contains(query) ||
          (movement.reason ?? '').toLowerCase().contains(query) ||
          (movement.referenceOrderId ?? '')
              .toLowerCase()
              .contains(query);

      final matchesMovement = _selectedMovement == 'all' ||
          movement.changeType == _selectedMovement;

      final movementDate = movement.createdAt.toLocal();

      final matchesDate = switch (_selectedDateRange) {
        'today' =>
        movementDate.year == now.year &&
            movementDate.month == now.month &&
            movementDate.day == now.day,
        '7days' => !movementDate.isBefore(
          now.subtract(const Duration(days: 7)),
        ),
        '30days' => !movementDate.isBefore(
          now.subtract(const Duration(days: 30)),
        ),
        _ => true,
      };

      return matchesSearch && matchesMovement && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'oldest':
          return a.createdAt.compareTo(b.createdAt);
        case 'newest':
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  // --------------------------------------------------
  // SEARCH AND FILTER UI
  // --------------------------------------------------

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
              hintText: 'Search reason, order ID or movement...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedMovement,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Movement',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'manual_adjustment',
                      child: Text('Adjustment'),
                    ),
                    DropdownMenuItem(
                      value: 'restock',
                      child: Text('Restock'),
                    ),
                    DropdownMenuItem(
                      value: 'order_placed',
                      child: Text('Order placed'),
                    ),
                    DropdownMenuItem(
                      value: 'order_cancelled',
                      child: Text('Cancelled'),
                    ),
                    DropdownMenuItem(
                      value: 'return',
                      child: Text('Return'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMovement = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDateRange,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All time'),
                    ),
                    DropdownMenuItem(
                      value: 'today',
                      child: Text('Today'),
                    ),
                    DropdownMenuItem(
                      value: '7days',
                      child: Text('7 days'),
                    ),
                    DropdownMenuItem(
                      value: '30days',
                      child: Text('30 days'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDateRange = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: _selectedSort,
            decoration: const InputDecoration(
              labelText: 'Sort by',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'newest',
                child: Text('Newest first'),
              ),
              DropdownMenuItem(
                value: 'oldest',
                child: Text('Oldest first'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSort = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DATE FORMAT
  // --------------------------------------------------

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  // --------------------------------------------------
  // MOVEMENT COLORS
  // --------------------------------------------------

  Color _movementColor(String type) {
    switch (type) {
      case 'restock':
      case 'order_cancelled':
      case 'return':
        return Colors.green;

      case 'order_placed':
        return Colors.orange;

      case 'manual_adjustment':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // --------------------------------------------------
  // MOVEMENT ICONS
  // --------------------------------------------------

  IconData _movementIcon(String type) {
    switch (type) {
      case 'restock':
        return Icons.inventory_2_outlined;

      case 'order_placed':
        return Icons.shopping_bag_outlined;

      case 'order_cancelled':
        return Icons.cancel_outlined;

      case 'return':
        return Icons.assignment_return_outlined;

      case 'manual_adjustment':
        return Icons.tune;

      default:
        return Icons.history;
    }
  }

  // --------------------------------------------------
  // MOVEMENT LABELS
  // --------------------------------------------------

  String _movementLabel(String type) {
    switch (type) {
      case 'restock':
        return 'Restock';

      case 'order_placed':
        return 'Order Placed';

      case 'order_cancelled':
        return 'Order Cancelled';

      case 'return':
        return 'Product Return';

      case 'manual_adjustment':
        return 'Manual Adjustment';

      default:
        return type.replaceAll('_', ' ');
    }
  }

  // --------------------------------------------------
  // STOCK MOVEMENT CARD
  // --------------------------------------------------

  Widget _buildMovementCard(
      BuildContext context,
      StockMovementEntity movement,
      ) {
    final color = _movementColor(movement.changeType);
    final isAddition = movement.quantityChange > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(
                    _movementIcon(movement.changeType),
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _movementLabel(movement.changeType),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _formatDate(movement.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                Text(
                  '${isAddition ? '+' : ''}${movement.quantityChange}',
                  style: TextStyle(
                    color: isAddition ? Colors.green : Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stockValue(
                  'Previous Stock',
                  movement.previousStock,
                ),

                const Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                ),

                _stockValue(
                  'New Stock',
                  movement.newStock,
                ),
              ],
            ),

            if (movement.reason != null &&
                movement.reason!.isNotEmpty) ...[
              const SizedBox(height: 16),

              Text(
                'Reason',
                style: Theme.of(context).textTheme.labelMedium,
              ),

              const SizedBox(height: 4),

              Text(movement.reason!),
            ],

            if (movement.changedBy != null) ...[
              const SizedBox(height: 10),

              Text(
                'Changed by: ${movement.changedBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            if (movement.referenceOrderId != null) ...[
              const SizedBox(height: 8),

              Text(
                'Order ID: ${movement.referenceOrderId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STOCK VALUE
  // --------------------------------------------------

  Widget _stockValue(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          '$value units',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // BUILD SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final movementsAsync = ref.watch(
      productStockMovementsProvider(widget.productId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock History'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(
                productStockMovementsProvider(widget.productId),
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.productName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildFilters(context),

          Expanded(
            child: movementsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 12),

                      const Text('Unable to load stock history'),

                      const SizedBox(height: 8),

                      Text(
                        '$error',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      FilledButton(
                        onPressed: () {
                          ref.invalidate(
                            productStockMovementsProvider(
                              widget.productId,
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              data: (movements) {
                final filteredMovements =
                _filterMovements(movements);

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      productStockMovementsProvider(widget.productId),
                    );

                    await ref.read(
                      productStockMovementsProvider(widget.productId).future,
                    );
                  },

                  child: filteredMovements.isEmpty
                      ? ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 70),

                      Icon(
                        movements.isEmpty
                            ? Icons.history
                            : Icons.search_off,
                        size: 56,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          movements.isEmpty
                              ? 'No stock movements recorded yet'
                              : 'No matching stock movements found',
                        ),
                      ),
                    ],
                  )
                      : ListView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    itemCount: filteredMovements.length,
                    itemBuilder: (context, index) {
                      return _buildMovementCard(
                        context,
                        filteredMovements[index],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
