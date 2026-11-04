import '../entities/payment_order_entity.dart';
import '../repositories/payment_repository.dart';

class CreateRazorpayOrderUseCase {
  final PaymentRepository repository;

  CreateRazorpayOrderUseCase(this.repository);

  Future<PaymentOrderEntity> call(String techShopOrderId) async {
    if (techShopOrderId.trim().isEmpty) {
      throw ArgumentError('TechShop order ID cannot be empty.');
    }

    return repository.createRazorpayOrder(techShopOrderId);
  }
}
