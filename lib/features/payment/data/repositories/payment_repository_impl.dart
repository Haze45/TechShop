import '../../domain/entities/payment_order_entity.dart';
import '../../domain/entities/payment_verification_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';
import '../models/payment_verification_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaymentOrderEntity> createRazorpayOrder(String techShopOrderId) async {
    return await remoteDataSource.createRazorpayOrder(techShopOrderId);
  }

  @override
  Future<bool> verifyPayment({
    required String techShopOrderId,
    required PaymentVerificationEntity verification,
  }) async {
    final verificationModel = PaymentVerificationModel(
      razorpayOrderId: verification.razorpayOrderId,
      razorpayPaymentId: verification.razorpayPaymentId,
      razorpaySignature: verification.razorpaySignature,
    );

    return await remoteDataSource.verifyPayment(
      techShopOrderId: techShopOrderId,
      verification: verificationModel,
    );
  }
}
