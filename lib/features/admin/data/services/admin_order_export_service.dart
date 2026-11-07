import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../../../orders/domain/entities/order_entity.dart';

class AdminOrderExportService {
  Future<void> exportOrders(List<OrderEntity> orders) async {
    final rows = <List<dynamic>>[
      [
        'Order Number',
        'Date',
        'Customer',
        'Phone',
        'City',
        'Order Status',
        'Payment Method',
        'Payment Status',
        'Items',
        'Subtotal',
        'Shipping Fee',
        'Tax',
        'Discount',
        'Total Amount',
      ],
    ];

    for (final order in orders) {
      final address = order.shippingAddress;

      rows.add([
        order.orderNumber,
        order.placedAt.toLocal().toIso8601String(),
        address['full_name'] ?? '',
        address['phone'] ?? '',
        address['city'] ?? '',
        order.status,
        order.paymentMethod ?? '',
        order.paymentStatus,
        order.totalItems,
        order.subtotal,
        order.shippingFee,
        order.tax,
        order.discount,
        order.totalAmount,
      ]);
    }

    final csvData = csv.encode(rows);

    final directory = await getTemporaryDirectory();

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    final file = File('${directory.path}/techshop_orders_$timestamp.csv');

    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'TechShop Orders Report',
        text: 'TechShop order export',
      ),
    );
  }
}
