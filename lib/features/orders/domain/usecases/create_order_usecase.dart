import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<String> call({
    required Map<String, dynamic> shippingAddress,
    String? notes,
  }) {
    if (shippingAddress.isEmpty) {
      throw ArgumentError('Shipping address cannot be empty.');
    }

    return repository.createOrder(
      shippingAddress: shippingAddress,
      notes: notes,
    );
  }
}