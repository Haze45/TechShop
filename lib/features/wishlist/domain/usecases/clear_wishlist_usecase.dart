import '../repositories/wishlist_repository.dart';

class ClearWishlistUseCase {
  final WishlistRepository repository;

  ClearWishlistUseCase(this.repository);

  Future<void> call(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    await repository.clearWishlist(userId);
  }
}
