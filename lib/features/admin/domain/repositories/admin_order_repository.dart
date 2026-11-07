import '../../../orders/domain/entities/order_entity.dart';

abstract class AdminOrderRepository {
  Future<List<OrderEntity>> getAllOrders();

  Future<OrderEntity> getOrderById(String orderId);

  Future<void> updateOrderStatus(String orderId, String newStatus);

  Future<void> cancelOrder(String orderId);
}
