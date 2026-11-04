import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders(String userId);

  Future<OrderEntity?> getOrderById({
    required String orderId,
    required String userId,
  });

  Future<String> createOrder({
    required Map<String, dynamic> shippingAddress,
    String? notes,
    String paymentMethod = 'cod',
  });

  Future<void> cancelOrder(String orderId);
}