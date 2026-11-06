import '../../domain/entities/cart_entity.dart';

class CartState {
  final CartEntity? cart;
  final bool isUpdating;

  const CartState({this.cart, this.isUpdating = false});

  int get totalItems => cart?.totalItems ?? 0;

  double get totalPrice => cart?.totalPrice ?? 0.0;

  bool get isEmpty => cart == null || cart!.isEmpty;

  bool get isNotEmpty => !isEmpty;

  CartState copyWith({CartEntity? cart, bool? isUpdating}) {
    return CartState(
      cart: cart ?? this.cart,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
