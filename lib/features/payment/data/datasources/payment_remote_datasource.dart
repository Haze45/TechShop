import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_order_model.dart';
import '../models/payment_verification_model.dart';

class PaymentRemoteDataSource {
  final SupabaseClient supabase;

  PaymentRemoteDataSource(this.supabase);

  // Create a Razorpay order through Supabase Edge Function
  Future<PaymentOrderModel> createRazorpayOrder(String techShopOrderId) async {
    final response = await supabase.functions.invoke(
      'create-razorpay-order',
      body: {'order_id': techShopOrderId},
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    return PaymentOrderModel.fromJson(data);
  }

  // Verify payment through Supabase Edge Function
  Future<bool> verifyPayment({
    required String techShopOrderId,
    required PaymentVerificationModel verification,
  }) async {
    final response = await supabase.functions.invoke(
      'verify-razorpay-payment',
      body: {'order_id': techShopOrderId, ...verification.toJson()},
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    return data['verified'] == true;
  }
}
