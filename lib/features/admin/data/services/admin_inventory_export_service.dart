import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../products/domain/entities/product_entity.dart';

class AdminInventoryExportService {
  static Future<void> exportInventory(List<ProductEntity> products) async {
    final rows = <List<dynamic>>[
      [
        'Product ID',
        'Product Name',
        'SKU',
        'Category ID',
        'Brand ID',
        'Price',
        'Stock Quantity',
        'Stock Status',
        'Inventory Value',
        'Active',
      ],
      ...products.map((product) {
        final stockStatus = product.stockQuantity <= 0
            ? 'Out of Stock'
            : product.stockQuantity <= 10
            ? 'Low Stock'
            : 'In Stock';

        return [
          product.id,
          product.name,
          product.sku,
          product.categoryId,
          product.brandId,
          product.price.toStringAsFixed(2),
          product.stockQuantity,
          stockStatus,
          (product.price * product.stockQuantity).toStringAsFixed(2),
          product.isActive ? 'Yes' : 'No',
        ];
      }),
    ];

    final csvContent = csv.encode(rows);
    final directory = await getTemporaryDirectory();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final file = File('${directory.path}/techshop_inventory_$timestamp.csv');

    await file.writeAsString(csvContent, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'TechShop Inventory Report',
        text: 'TechShop inventory export',
      ),
    );
  }
}
