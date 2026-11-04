import '../../domain/entities/payment_order_entity.dart';

class PaymentState {
  final PaymentOrderEntity? paymentOrder;
  final bool isProcessing;
  final bool isVerified;
  final String? errorMessage;

  const PaymentState({
    this.paymentOrder,
    this.isProcessing = false,
    this.isVerified = false,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentOrderEntity? paymentOrder,
    bool? isProcessing,
    bool? isVerified,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      paymentOrder: paymentOrder ?? this.paymentOrder,
      isProcessing: isProcessing ?? this.isProcessing,
      isVerified: isVerified ?? this.isVerified,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
