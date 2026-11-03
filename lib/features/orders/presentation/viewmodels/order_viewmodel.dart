import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';

import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';
import 'order_state.dart';

// =========================================
// ORDER VIEWMODEL
// =========================================

class OrderViewModel extends AsyncNotifier<OrderState> {

  @override
  Future<OrderState> build() async {
    // Watch authentication state.
    final authState = ref.watch(authViewModelProvider);

    final user = authState.value;

    // If user is not logged in, return empty state.
    if (user == null) {
      return const OrderState();
    }

    // Load orders for logged-in user.
    final orders = await ref
        .read(getOrdersUseCaseProvider)
        .call(user.id);

    return OrderState(orders: orders);
  }

  // =========================================
  // LOAD ORDERS
  // =========================================

  Future<void> loadOrders() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.value;

    if (user == null) {
      state = const AsyncData(OrderState());
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final orders = await ref
          .read(getOrdersUseCaseProvider)
          .call(user.id);

      return OrderState(orders: orders);
    });
  }

  // =========================================
  // REFRESH ORDERS
  // =========================================

  Future<void> refreshOrders() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.value;

    if (user == null) {
      state = const AsyncData(OrderState());
      return;
    }

    final currentState = state.value ?? const OrderState();

    state = AsyncData(
      currentState.copyWith(isRefreshing: true),
    );

    try {
      final orders = await ref
          .read(getOrdersUseCaseProvider)
          .call(user.id);

      state = AsyncData(
        OrderState(orders: orders),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // =========================================
  // GET ORDER BY ID
  // =========================================

  Future<OrderEntity?> getOrderById(String orderId) async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.value;

    if (user == null) {
      throw Exception('Please log in to view your order.');
    }

    return await ref
        .read(getOrderByIdUseCaseProvider)
        .call(
      orderId: orderId,
      userId: user.id,
    );
  }
}

// =========================================
// ORDER VIEWMODEL PROVIDER
// =========================================

final orderViewModelProvider =
AsyncNotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);