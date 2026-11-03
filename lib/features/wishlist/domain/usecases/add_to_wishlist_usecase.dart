import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase {
  final WishlistRepository repository;

  AddToWishlistUseCase(this.repository);

  Future<void> call({required String userId, required String productId}) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    if (productId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    await repository.addToWishlist(userId: userId, productId: productId);
  }
}
