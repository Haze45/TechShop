import '../../domain/entities/payment_order_entity.dart';

class PaymentOrderModel extends PaymentOrderEntity {
  const PaymentOrderModel({
    required super.razorpayOrderId,
    required super.amount,
    required super.currency,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    return PaymentOrderModel(
      razorpayOrderId: json['razorpay_order_id'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpay_order_id': razorpayOrderId,
      'amount': amount,
      'currency': currency,
    };
  }
}
