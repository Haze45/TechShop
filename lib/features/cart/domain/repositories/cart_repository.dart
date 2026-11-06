import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<String> getOrCreateCart(String userId);

  Future<CartEntity?> getCart(String userId);

  Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  });

  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  });

  Future<void> removeCartItem(String itemId);

  Future<void> clearCart(String userId);
}
