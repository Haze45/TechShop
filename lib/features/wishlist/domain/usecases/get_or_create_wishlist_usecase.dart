import '../repositories/wishlist_repository.dart';

class GetOrCreateWishlistUseCase {
  final WishlistRepository repository;

  GetOrCreateWishlistUseCase(this.repository);

  Future<String> call(String userId) {
    return repository.getOrCreateWishlist(userId);
  }
}
