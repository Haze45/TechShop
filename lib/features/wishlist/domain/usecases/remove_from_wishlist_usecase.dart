import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  final WishlistRepository repository;

  RemoveFromWishlistUseCase(this.repository);

  Future<void> call({required String userId, required String productId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    if (productId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    await repository.removeFromWishlist(userId: userId, productId: productId);
  }
}
