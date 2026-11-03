import '../../domain/entities/order_entity.dart';

class OrderState {
  final List<OrderEntity> orders;
  final bool isRefreshing;

  const OrderState({
    this.orders = const [],
    this.isRefreshing = false,
  });

  int get totalOrders => orders.length;

  bool get isEmpty => orders.isEmpty;

  bool get isNotEmpty => orders.isNotEmpty;

  OrderState copyWith({
    List<OrderEntity>? orders,
    bool? isRefreshing,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}