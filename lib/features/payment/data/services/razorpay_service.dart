import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late final Razorpay _razorpay;

  RazorpayService({
    required void Function(PaymentSuccessResponse response) onPaymentSuccess,
    required void Function(PaymentFailureResponse response) onPaymentError,
    required void Function(ExternalWalletResponse response) onExternalWallet,
  }) {
    _razorpay = Razorpay();

    // Listen for successful payments
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onPaymentSuccess);

    // Listen for failed payments
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onPaymentError);

    // Listen for external wallet selection
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  // Open Razorpay Checkout
  void openCheckout(Map<String, dynamic> options) {
    _razorpay.open(options);
  }

  // Remove event listeners
  void dispose() {
    _razorpay.clear();
  }
}
