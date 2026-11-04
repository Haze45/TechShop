import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';

import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/create_razorpay_order_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);

  return PaymentRemoteDataSource(supabase);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);

  return PaymentRepositoryImpl(remoteDataSource);
});

final createRazorpayOrderUseCaseProvider =
Provider<CreateRazorpayOrderUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);

  return CreateRazorpayOrderUseCase(repository);
});

final verifyPaymentUseCaseProvider =
Provider<VerifyPaymentUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);

  return VerifyPaymentUseCase(repository);
});
