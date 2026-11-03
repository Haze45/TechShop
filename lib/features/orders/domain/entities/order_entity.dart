import 'order_item_entity.dart';

class OrderEntity {
  final String id;
  final String orderNumber;
  final String userId;

  final String status;
  final String paymentStatus;
  final String? paymentMethod;

  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final double totalAmount;

  final Map<String, dynamic> shippingAddress;

  final String? notes;

  final DateTime placedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.shippingAddress,
    this.notes,
    required this.placedAt,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  int get totalItems =>
      items.fold(0, (total, item) => total + item.quantity);

  bool get isPending => status == 'pending';

  bool get isConfirmed => status == 'confirmed';

  bool get isProcessing => status == 'processing';

  bool get isShipped => status == 'shipped';

  bool get isDelivered => status == 'delivered';

  bool get isCancelled => status == 'cancelled';

  bool get isPaid => paymentStatus == 'paid';

  bool get isPaymentPending => paymentStatus == 'pending';
}