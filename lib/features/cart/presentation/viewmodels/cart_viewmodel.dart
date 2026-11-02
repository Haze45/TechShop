import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_providers.dart';
import 'cart_state.dart';

class CartViewModel extends AsyncNotifier<CartState> {
  @override
  Future<CartState> build() async {
    final supabase = ref.read(supabaseProvider);

    final user = supabase.auth.currentUser;

    // No cart when the user is logged out.
    if (user == null) {
      return const CartState();
    }

    final cart = await ref.read(getCartUseCaseProvider)(user.id);

    return CartState(cart: cart);
  }

  CartState get _currentState {
    return state.value ?? const CartState();
  }

  // Refresh the current user's cart.
  Future<void> loadCart() async {
    final user = ref.read(supabaseProvider).auth.currentUser;

    if (user == null) {
      state = const AsyncData(CartState());
      return;
    }

    state = const AsyncLoading();

    try {
      final cart = await ref.read(getCartUseCaseProvider)(user.id);

      state = AsyncData(CartState(cart: cart));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Add a product to the cart.
  Future<void> addToCart({required String productId, int quantity = 1}) async {
    final user = ref.read(supabaseProvider).auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to add products to your cart.');
    }

    await _performCartOperation(() async {
      await ref.read(addToCartUseCaseProvider)(
        userId: user.id,
        productId: productId,
        quantity: quantity,
      );
    });
  }

  // Update the quantity of a cart item.
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    await _performCartOperation(() async {
      await ref.read(updateCartItemQuantityUseCaseProvider)(
        itemId: itemId,
        quantity: quantity,
      );
    });
  }

  // Increase the quantity of a cart item.
  Future<void> increaseQuantity(String itemId, int currentQuantity) {
    return updateQuantity(itemId: itemId, quantity: currentQuantity + 1);
  }

  // Decrease the quantity of a cart item.
  Future<void> decreaseQuantity(String itemId, int currentQuantity) {
    if (currentQuantity <= 1) {
      return removeItem(itemId);
    }

    return updateQuantity(itemId: itemId, quantity: currentQuantity - 1);
  }

  // Remove one item from the cart.
  Future<void> removeItem(String itemId) async {
    await _performCartOperation(() async {
      await ref.read(removeCartItemUseCaseProvider)(itemId);
    });
  }

  // Remove all items from the cart.
  Future<void> clearCart() async {
    final user = ref.read(supabaseProvider).auth.currentUser;

    if (user == null) {
      state = const AsyncData(CartState());
      return;
    }

    await _performCartOperation(() async {
      await ref.read(clearCartUseCaseProvider)(user.id);
    });
  }

  // Perform an operation and reload the cart.
  Future<void> _performCartOperation(Future<void> Function() operation) async {
    final current = _currentState;

    state = AsyncData(current.copyWith(isUpdating: true));

    try {
      await operation();

      final user = ref.read(supabaseProvider).auth.currentUser;

      if (user == null) {
        state = const AsyncData(CartState());
        return;
      }

      final cart = await ref.read(getCartUseCaseProvider)(user.id);

      state = AsyncData(CartState(cart: cart));
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isUpdating: false));

      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final cartViewModelProvider = AsyncNotifierProvider<CartViewModel, CartState>(
  CartViewModel.new,
);
