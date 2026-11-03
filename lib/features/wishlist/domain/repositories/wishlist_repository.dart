import '../entities/wishlist_entity.dart';

abstract class WishlistRepository {
  // Get or create a user's wishlist.
  Future<String> getOrCreateWishlist(String userId);

  // Get wishlist with all saved products.
  Future<WishlistEntity?> getWishlist(String userId);

  // Add a product.
  Future<void> addToWishlist({
    required String userId,
    required String productId,
  });

  // Remove a product.
  Future<void> removeFromWishlist({
    required String userId,
    required String productId,
  });

  // Remove all products.
  Future<void> clearWishlist(String userId);
}
