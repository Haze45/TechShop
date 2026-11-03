import '../../domain/entities/order_entity.dart';

class OrderState {
  final List<OrderEntity> orders;
  final bool isRefreshing;
  final bool isSubmitting;

  const OrderState({
    this.orders = const [],
    this.isRefreshing = false,
    this.isSubmitting = false,
  });

  int get totalOrders => orders.length;

  bool get isEmpty => orders.isEmpty;

  bool get isNotEmpty => orders.isNotEmpty;

  OrderState copyWith({
    List<OrderEntity>? orders,
    bool? isRefreshing,
    bool? isSubmitting,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
