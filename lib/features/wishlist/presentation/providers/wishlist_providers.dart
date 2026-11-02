import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/repositories/wishlist_repository_impl.dart';

import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/get_or_create_wishlist_usecase.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import '../../domain/usecases/clear_wishlist_usecase.dart';

// =========================================
// 1. REMOTE DATA SOURCE PROVIDER
// =========================================

final wishlistRemoteDataSourceProvider = Provider<WishlistRemoteDataSource>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);

  return WishlistRemoteDataSource(supabase);
});

// =========================================
// 2. REPOSITORY PROVIDER
// =========================================

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);

  return WishlistRepositoryImpl(remoteDataSource);
});

// =========================================
// 3. GET WISHLIST USE CASE PROVIDER
// =========================================

final getWishlistUseCaseProvider = Provider<GetWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);

  return GetWishlistUseCase(repository);
});

// =========================================
// 4. GET OR CREATE WISHLIST USE CASE PROVIDER
// =========================================

final getOrCreateWishlistUseCaseProvider = Provider<GetOrCreateWishlistUseCase>(
  (ref) {
    final repository = ref.watch(wishlistRepositoryProvider);

    return GetOrCreateWishlistUseCase(repository);
  },
);

// =========================================
// 5. ADD TO WISHLIST USE CASE PROVIDER
// =========================================

final addToWishlistUseCaseProvider = Provider<AddToWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);

  return AddToWishlistUseCase(repository);
});

// =========================================
// 6. REMOVE FROM WISHLIST USE CASE PROVIDER
// =========================================

final removeFromWishlistUseCaseProvider = Provider<RemoveFromWishlistUseCase>((
  ref,
) {
  final repository = ref.watch(wishlistRepositoryProvider);

  return RemoveFromWishlistUseCase(repository);
});

// =========================================
// 7. CLEAR WISHLIST USE CASE PROVIDER
// =========================================

final clearWishlistUseCaseProvider = Provider<ClearWishlistUseCase>((ref) {
  final repository = ref.watch(wishlistRepositoryProvider);

  return ClearWishlistUseCase(repository);
});
