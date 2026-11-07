import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/admin_order_remote_datasource.dart';
import '../../data/repositories/admin_order_repository_impl.dart';
import '../../domain/repositories/admin_order_repository.dart';

import '../../../orders/domain/entities/order_entity.dart';

// Data source
final adminOrderRemoteDataSourceProvider = Provider<AdminOrderRemoteDataSource>(
  (ref) {
    final supabase = ref.watch(supabaseProvider);
    return AdminOrderRemoteDataSource(supabase);
  },
);

// Repository
final adminOrderRepositoryProvider = Provider<AdminOrderRepository>((ref) {
  final remoteDataSource = ref.watch(adminOrderRemoteDataSourceProvider);

  return AdminOrderRepositoryImpl(remoteDataSource);
});

// Fetch all orders
final adminOrdersProvider = FutureProvider<List<OrderEntity>>((ref) {
  return ref.watch(adminOrderRepositoryProvider).getAllOrders();
});

// Fetch individual order
final adminOrderByIdProvider = FutureProvider.family<OrderEntity, String>((
  ref,
  orderId,
) {
  return ref.watch(adminOrderRepositoryProvider).getOrderById(orderId);
});

final adminOrderStatusUpdateProvider =
    AsyncNotifierProvider<AdminOrderStatusUpdateNotifier, void>(
      AdminOrderStatusUpdateNotifier.new,
    );

class AdminOrderStatusUpdateNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus(String orderId, String newStatus) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(adminOrderRepositoryProvider)
          .updateOrderStatus(orderId, newStatus);
    });
  }
}

final adminOrderCancellationProvider =
AsyncNotifierProvider<AdminOrderCancellationNotifier, void>(
  AdminOrderCancellationNotifier.new,
);

class AdminOrderCancellationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> cancelOrder(String orderId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(adminOrderRepositoryProvider)
          .cancelOrder(orderId);
    });
  }
}
