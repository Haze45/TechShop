import '../entities/payment_order_entity.dart';
import '../entities/payment_verification_entity.dart';

abstract class PaymentRepository {
  Future<PaymentOrderEntity> createRazorpayOrder(String techShopOrderId);

  Future<bool> verifyPayment({
    required String techShopOrderId,
    required PaymentVerificationEntity verification,
  });
}
