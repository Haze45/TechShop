import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/repositories/admin_order_repository.dart';
import '../datasources/admin_order_remote_datasource.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  final AdminOrderRemoteDataSource remoteDataSource;

  AdminOrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<OrderEntity>> getAllOrders() {
    return remoteDataSource.getAllOrders();
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) {
    return remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) {
    return remoteDataSource.updateOrderStatus(orderId, newStatus);
  }

  @override
  Future<void> cancelOrder(String orderId) {
    return remoteDataSource.cancelOrder(orderId);
  }
}
