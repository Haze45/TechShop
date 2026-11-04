import '../../domain/entities/payment_verification_entity.dart';

class PaymentVerificationModel extends PaymentVerificationEntity {
  const PaymentVerificationModel({
    required super.razorpayOrderId,
    required super.razorpayPaymentId,
    required super.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
  }
}
