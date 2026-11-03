import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  Future<void> call(String orderId) async {
    if (orderId.trim().isEmpty) {
      throw ArgumentError('Order ID cannot be empty.');
    }

    await repository.cancelOrder(orderId);
  }
}