import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> getOrCreateCart(String userId) {
    return remoteDataSource.getOrCreateCart(userId);
  }

  @override
  Future<CartEntity?> getCart(String userId) {
    return remoteDataSource.getCart(userId);
  }

  @override
  Future<void> addToCart({
    required String userId,
    required String productId,
    int quantity = 1,
  }) async {
    final cartId = await remoteDataSource.getOrCreateCart(userId);

    await remoteDataSource.addToCart(
      cartId: cartId,
      productId: productId,
      quantity: quantity,
    );
  }

  @override
  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) {
    return remoteDataSource.updateCartItemQuantity(
      itemId: itemId,
      quantity: quantity,
    );
  }

  @override
  Future<void> removeCartItem(String itemId) {
    return remoteDataSource.removeCartItem(itemId);
  }

  @override
  Future<void> clearCart(String userId) async {
    final cartId = await remoteDataSource.getOrCreateCart(userId);

    await remoteDataSource.clearCart(cartId);
  }
}
