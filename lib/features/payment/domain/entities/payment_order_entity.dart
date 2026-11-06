class PaymentOrderEntity {
  final String razorpayOrderId;
  final int amount;
  final String currency;

  const PaymentOrderEntity({
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
  });

  // Razorpay expects the amount in the smallest currency unit.
  // For INR, 100 paise = ₹1.
  double get amountInRupees => amount / 100.0;
}
