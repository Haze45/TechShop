import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/wishlist_entity.dart';
import '../providers/wishlist_providers.dart';
import 'wishlist_state.dart';

// =========================================
// WISHLIST VIEWMODEL
// =========================================

class WishlistViewModel extends AsyncNotifier<WishlistState> {
  @override
  Future<WishlistState> build() async {
    // Watch authentication state.
    // Rebuild when the user logs in or logs out.
    final authState = ref.watch(authViewModelProvider);

    final user = authState.value;

    // No authenticated user.
    if (user == null) {
      return const WishlistState();
    }

    // Load the authenticated user's wishlist.
    final wishlist = await ref.read(getWishlistUseCaseProvider).call(user.id);

    return WishlistState(wishlist: wishlist);
  }

  // =========================================
  // CURRENT STATE
  // =========================================

  WishlistState get _currentState {
    return state.value ?? const WishlistState();
  }

  // =========================================
  // LOAD WISHLIST
  // =========================================

  Future<void> loadWishlist() async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.value;

    if (user == null) {
      state = const AsyncData(WishlistState());
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final wishlist = await ref.read(getWishlistUseCaseProvider).call(user.id);

      return WishlistState(wishlist: wishlist);
    });
  }

  // =========================================
  // ADD PRODUCT TO WISHLIST
  // =========================================

  Future<void> addToWishlist(String productId) async {
    final user = ref.read(authViewModelProvider).value;

    if (user == null) {
      throw Exception('Please log in to use your wishlist.');
    }

    await _performWishlistOperation(() async {
      await ref
          .read(addToWishlistUseCaseProvider)
          .call(userId: user.id, productId: productId);
    });
  }

  // =========================================
  // REMOVE PRODUCT FROM WISHLIST
  // =========================================

  Future<void> removeFromWishlist(String productId) async {
    final user = ref.read(authViewModelProvider).value;

    if (user == null) {
      throw Exception('Please log in to use your wishlist.');
    }

    await _performWishlistOperation(() async {
      await ref
          .read(removeFromWishlistUseCaseProvider)
          .call(userId: user.id, productId: productId);
    });
  }

  // =========================================
  // CLEAR WISHLIST
  // =========================================

  Future<void> clearWishlist() async {
    final user = ref.read(authViewModelProvider).value;

    if (user == null) {
      throw Exception('Please log in to use your wishlist.');
    }

    await _performWishlistOperation(() async {
      await ref.read(clearWishlistUseCaseProvider).call(user.id);
    });
  }

  // =========================================
  // CHECK PRODUCT
  // =========================================

  bool isProductInWishlist(String productId) {
    return _currentState.containsProduct(productId);
  }

  // =========================================
  // COMMON WISHLIST OPERATION
  // =========================================

  Future<void> _performWishlistOperation(
    Future<void> Function() operation,
  ) async {
    final previousState = _currentState;

    state = AsyncData(previousState.copyWith(isUpdating: true));

    try {
      await operation();

      // Reload wishlist after successful operation.
      final user = ref.read(authViewModelProvider).value;

      if (user == null) {
        state = const AsyncData(WishlistState());
        return;
      }

      final wishlist = await ref.read(getWishlistUseCaseProvider).call(user.id);

      state = AsyncData(WishlistState(wishlist: wishlist));
    } catch (error, stackTrace) {
      // Restore previous state if operation fails.
      state = AsyncData(previousState);

      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

// =========================================
// WISHLIST VIEWMODEL PROVIDER
// =========================================

final wishlistViewModelProvider =
    AsyncNotifierProvider<WishlistViewModel, WishlistState>(
      WishlistViewModel.new,
    );
