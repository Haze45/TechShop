import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders(String userId) async {
    return await remoteDataSource.getOrders(userId);
  }

  @override
  Future<OrderEntity?> getOrderById({
    required String orderId,
    required String userId,
  }) async {
    return await remoteDataSource.getOrderById(
      orderId: orderId,
      userId: userId,
    );
  }
}