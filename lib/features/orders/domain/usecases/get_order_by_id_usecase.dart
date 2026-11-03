import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<OrderEntity?> call({
    required String orderId,
    required String userId,
  }) {
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order ID cannot be empty.');
    }

    if (userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    return repository.getOrderById(
      orderId: orderId,
      userId: userId,
    );
  }
}