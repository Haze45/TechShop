import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_order_entity.dart';
import '../../domain/entities/payment_verification_entity.dart';
import '../providers/payment_providers.dart';
import 'payment_state.dart';

class PaymentViewModel extends AsyncNotifier<PaymentState> {
  @override
  Future<PaymentState> build() async {
    return const PaymentState();
  }

  // Create Razorpay payment order
  Future<PaymentOrderEntity> createPaymentOrder(String techShopOrderId) async {
    final currentState = state.value ?? const PaymentState();

    if (currentState.isProcessing) {
      throw Exception('A payment operation is already in progress.');
    }

    state = AsyncData(
      currentState.copyWith(
        isProcessing: true,
        isVerified: false,
        clearError: true,
      ),
    );

    try {
      final paymentOrder = await ref
          .read(createRazorpayOrderUseCaseProvider)
          .call(techShopOrderId);

      state = AsyncData(PaymentState(paymentOrder: paymentOrder));

      return paymentOrder;
    } catch (error) {
      state = AsyncData(
        currentState.copyWith(
          isProcessing: false,
          errorMessage: error.toString(),
        ),
      );

      rethrow;
    }
  }

  // Verify Razorpay payment
  Future<bool> verifyPayment({
    required String techShopOrderId,
    required PaymentVerificationEntity verification,
  }) async {
    final currentState = state.value ?? const PaymentState();

    if (currentState.isProcessing) {
      throw Exception('A payment operation is already in progress.');
    }

    state = AsyncData(
      currentState.copyWith(isProcessing: true, clearError: true),
    );

    try {
      final isVerified = await ref
          .read(verifyPaymentUseCaseProvider)
          .call(techShopOrderId: techShopOrderId, verification: verification);

      state = AsyncData(
        currentState.copyWith(
          isProcessing: false,
          isVerified: isVerified,
          errorMessage: isVerified ? null : 'Payment verification failed.',
          clearError: isVerified,
        ),
      );

      return isVerified;
    } catch (error) {
      state = AsyncData(
        currentState.copyWith(
          isProcessing: false,
          errorMessage: error.toString(),
        ),
      );

      rethrow;
    }
  }

  // Reset payment state
  void resetPayment() {
    state = const AsyncData(PaymentState());
  }
}

final paymentViewModelProvider =
    AsyncNotifierProvider<PaymentViewModel, PaymentState>(PaymentViewModel.new);
