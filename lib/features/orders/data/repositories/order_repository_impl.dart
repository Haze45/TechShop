import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders(String userId) async {
    return remoteDataSource.getOrders(userId);
  }

  @override
  Future<OrderEntity?> getOrderById({
    required String orderId,
    required String userId,
  }) async {
    return remoteDataSource.getOrderById(
      orderId: orderId,
      userId: userId,
    );
  }

  @override
  Future<String> createOrder({
    required Map<String, dynamic> shippingAddress,
    String? notes,
  }) async {
    return remoteDataSource.createOrder(
      shippingAddress: shippingAddress,
      notes: notes,
    );
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await remoteDataSource.cancelOrder(orderId);
  }
}