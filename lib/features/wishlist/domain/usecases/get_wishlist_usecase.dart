import '../entities/wishlist_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final WishlistRepository repository;

  GetWishlistUseCase(this.repository);

  Future<WishlistEntity?> call(String userId) {
    return repository.getWishlist(userId);
  }
}
