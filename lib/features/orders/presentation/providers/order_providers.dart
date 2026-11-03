import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/order_remote_datasource.dart';
import '../../data/repositories/order_repository_impl.dart';

import '../../domain/repositories/order_repository.dart';

import '../../domain/usecases/cancel_order_usecase.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';

// =========================================
// REMOTE DATA SOURCE PROVIDER
// =========================================

final orderRemoteDataSourceProvider =
Provider<OrderRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return OrderRemoteDataSource(supabase);
});

// =========================================
// REPOSITORY PROVIDER
// =========================================

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);

  return OrderRepositoryImpl(remoteDataSource);
});

// =========================================
// GET ORDERS USE CASE PROVIDER
// =========================================

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);

  return GetOrdersUseCase(repository);
});

// =========================================
// GET ORDER BY ID USE CASE PROVIDER
// =========================================

final getOrderByIdUseCaseProvider =
Provider<GetOrderByIdUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);

  return GetOrderByIdUseCase(repository);

});

// =========================================
// CREATE ORDER USE CASE PROVIDER
// =========================================

final createOrderUseCaseProvider =
Provider<CreateOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);

  return CreateOrderUseCase(repository);
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return CancelOrderUseCase(repository);
});