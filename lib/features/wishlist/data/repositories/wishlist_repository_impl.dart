import '../../domain/entities/wishlist_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl(this.remoteDataSource);

  @override
  Future<String> getOrCreateWishlist(String userId) {
    return remoteDataSource.getOrCreateWishlist(userId);
  }

  @override
  Future<WishlistEntity?> getWishlist(String userId) {
    return remoteDataSource.getWishlist(userId);
  }

  @override
  Future<void> addToWishlist({
    required String userId,
    required String productId,
  }) async {
    final wishlistId = await remoteDataSource.getOrCreateWishlist(userId);

    await remoteDataSource.addToWishlist(
      wishlistId: wishlistId,
      productId: productId,
    );
  }

  @override
  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    final wishlistId = await remoteDataSource.getOrCreateWishlist(userId);

    await remoteDataSource.removeFromWishlist(
      wishlistId: wishlistId,
      productId: productId,
    );
  }

  @override
  Future<void> clearWishlist(String userId) async {
    final wishlistId = await remoteDataSource.getOrCreateWishlist(userId);

    await remoteDataSource.clearWishlist(wishlistId);
  }
}
