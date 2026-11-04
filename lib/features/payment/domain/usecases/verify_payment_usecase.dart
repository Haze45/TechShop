import '../entities/payment_verification_entity.dart';
import '../repositories/payment_repository.dart';

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<bool> call({
    required String techShopOrderId,
    required PaymentVerificationEntity verification,
  }) async {
    if (techShopOrderId.trim().isEmpty) {
      throw ArgumentError('TechShop order ID cannot be empty.');
    }

    if (verification.razorpayOrderId.trim().isEmpty ||
        verification.razorpayPaymentId.trim().isEmpty ||
        verification.razorpaySignature.trim().isEmpty) {
      throw ArgumentError('Payment verification details cannot be empty.');
    }

    return repository.verifyPayment(
      techShopOrderId: techShopOrderId,
      verification: verification,
    );
  }
}
