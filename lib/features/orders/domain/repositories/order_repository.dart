import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders(String userId);

  Future<OrderEntity?> getOrderById({
    required String orderId,
    required String userId,
  });
}