import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<String> call({
    required Map<String, dynamic> shippingAddress,
    String? notes,
    String paymentMethod = 'cod',
  }) {
    if (shippingAddress.isEmpty) {
      throw ArgumentError('Shipping address cannot be empty.');
    }

    if (!['cod', 'razorpay'].contains(paymentMethod)) {
      throw ArgumentError('Invalid payment method.');
    }

    return repository.createOrder(
      shippingAddress: shippingAddress,
      notes: notes,
      paymentMethod: paymentMethod,
    );
  }
}
