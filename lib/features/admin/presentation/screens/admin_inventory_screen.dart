import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/stock_movement_providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/services/admin_inventory_export_service.dart';

class AdminInventoryScreen extends ConsumerWidget {
  const AdminInventoryScreen({super.key});

  Color _stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }

  String _stockLabel(int stock) {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 10) return 'Low Stock';
    return 'In Stock';
  }

  // --------------------------------------------------
  // EXPORT INVENTORY
  // --------------------------------------------------

  Future<void> _exportInventory(
    BuildContext context,
    List<ProductEntity> products,
  ) async {
    try {
      await AdminInventoryExportService.exportInventory(products);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventory report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inventory export failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --------------------------------------------------
  // BUILD SCREEN
  // --------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(inventoryProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(inventoryProductsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load inventory: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(inventoryProductsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final totalProducts = products.length;

          final totalStockUnits = products.fold<int>(
            0,
            (total, product) => total + product.stockQuantity,
          );

          final lowStock = products
              .where((p) => p.stockQuantity > 0 && p.stockQuantity <= 10)
              .length;

          final outOfStock = products.where((p) => p.stockQuantity <= 0).length;

          // Estimated value based on selling price and available stock.
          final inventoryValue = products.fold<double>(
            0,
            (total, product) => total + (product.price * product.stockQuantity),
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(inventoryProductsProvider);
              await ref.read(inventoryProductsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(
                  totalProducts: totalProducts,
                  totalStockUnits: totalStockUnits,
                  lowStock: lowStock,
                  outOfStock: outOfStock,
                  inventoryValue: inventoryValue,
                ),

                const SizedBox(height: 20),

                // Product heading and export button
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'All Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        _exportInventory(context, products);
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ...products.map(
                  (product) => _buildProductCard(context, ref, product),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // INVENTORY SUMMARY
  // --------------------------------------------------

  Widget _buildSummary({
    required int totalProducts,
    required int totalStockUnits,
    required int lowStock,
    required int outOfStock,
    required double inventoryValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _summaryCard('Total Products', totalProducts, Colors.blue),
            _summaryCard('Stock Units', totalStockUnits, Colors.indigo),
            _summaryCard('Low Stock', lowStock, Colors.orange),
            _summaryCard('Out of Stock', outOfStock, Colors.red),
          ],
        ),

        const SizedBox(height: 10),

        _inventoryValueCard(inventoryValue),
      ],
    );
  }

  Widget _summaryCard(String title, int value, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                title == 'Total Products'
                    ? Icons.inventory_2_outlined
                    : title == 'Stock Units'
                    ? Icons.widgets_outlined
                    : title == 'Low Stock'
                    ? Icons.warning_amber_rounded
                    : Icons.remove_shopping_cart_outlined,
                color: color,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inventoryValueCard(double value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.currency_rupee,
                color: Colors.green,
                size: 28,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Inventory Value',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '₹${value.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Selling price × available stock',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // PRODUCT CARD
  // --------------------------------------------------

  Widget _buildProductCard(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) {
    final stockColor = _stockColor(product.stockQuantity);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.devices, size: 32, color: Colors.grey),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'SKU: ${product.sku}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          color: stockColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          _stockLabel(product.stockQuantity),
                          style: TextStyle(color: stockColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Stock history',
                  onPressed: () {
                    context.push(
                      '/admin/inventory/history/${product.id}',
                      extra: product.name,
                    );
                  },
                  icon: const Icon(Icons.history),
                ),

                IconButton(
                  tooltip: 'Adjust stock',
                  onPressed: () {
                    _showStockAdjustmentDialog(context, ref, product);
                  },
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // STOCK ADJUSTMENT DIALOG
  // --------------------------------------------------

  Future<void> _showStockAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    int adjustmentType = 1;
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adjust Product Stock'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Text('Current Stock: ${product.stockQuantity}'),

                    const SizedBox(height: 20),

                    const Text(
                      'Adjustment Type',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 8),

                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 1,
                          label: Text('Add'),
                          icon: Icon(Icons.add),
                        ),
                        ButtonSegment(
                          value: -1,
                          label: Text('Remove'),
                          icon: Icon(Icons.remove),
                        ),
                      ],
                      selected: {adjustmentType},
                      onSelectionChanged: isLoading
                          ? null
                          : (selection) {
                              setDialogState(() {
                                adjustmentType = selection.first;
                              });
                            },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: reasonController,
                      enabled: !isLoading,
                      maxLength: 500,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Why are you adjusting stock?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final quantity = int.tryParse(
                            quantityController.text.trim(),
                          );

                          final reason = reasonController.text.trim();

                          if (quantity == null || quantity <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enter a valid quantity greater than zero',
                                ),
                              ),
                            );
                            return;
                          }

                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please provide an adjustment reason',
                                ),
                              ),
                            );
                            return;
                          }

                          final signedQuantity = quantity * adjustmentType;

                          if (product.stockQuantity + signedQuantity < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Insufficient stock for this adjustment',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isLoading = true;
                          });

                          try {
                            await ref
                                .read(stockMovementRepositoryProvider)
                                .adjustProductStock(
                                  productId: product.id,
                                  quantityChange: signedQuantity,
                                  reason: reason,
                                );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (error) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isLoading = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Stock adjustment failed: $error',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },

                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Stock'),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();
    reasonController.dispose();

    if (result == true) {
      ref.invalidate(inventoryProductsProvider);
      ref.invalidate(allStockMovementsProvider);
      ref.invalidate(productStockMovementsProvider(product.id));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product stock updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
