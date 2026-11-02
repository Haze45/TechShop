import '../../domain/entities/wishlist_entity.dart';

class WishlistState {
  final WishlistEntity? wishlist;
  final bool isUpdating;

  const WishlistState({this.wishlist, this.isUpdating = false});

  // Total saved products.
  int get totalItems => wishlist?.totalItems ?? 0;

  // Check whether wishlist is empty.
  bool get isEmpty => wishlist == null || wishlist!.isEmpty;

  bool get isNotEmpty => !isEmpty;

  // Check whether a product is already saved.
  bool containsProduct(String productId) {
    return wishlist?.containsProduct(productId) ?? false;
  }

  WishlistState copyWith({
    WishlistEntity? wishlist,
    bool? isUpdating,
    bool clearWishlist = false,
  }) {
    return WishlistState(
      wishlist: clearWishlist ? null : wishlist ?? this.wishlist,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
