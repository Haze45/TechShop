import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

// Data
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';

// Domain
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/get_or_create_cart_usecase.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';

// 1. Cart Remote Data Source Provider
final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource(ref.watch(supabaseProvider));
});

// 2. Cart Repository Provider
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartRemoteDataSourceProvider));
});

// 3. Get Cart Use Case Provider
final getCartUseCaseProvider = Provider<GetCartUseCase>((ref) {
  return GetCartUseCase(ref.watch(cartRepositoryProvider));
});

// 4. Get or Create Cart Use Case Provider
final getOrCreateCartUseCaseProvider = Provider<GetOrCreateCartUseCase>((ref) {
  return GetOrCreateCartUseCase(ref.watch(cartRepositoryProvider));
});

// 5. Add to Cart Use Case Provider
final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.watch(cartRepositoryProvider));
});

// 6. Update Cart Item Quantity Use Case Provider
final updateCartItemQuantityUseCaseProvider =
    Provider<UpdateCartItemQuantityUseCase>((ref) {
      return UpdateCartItemQuantityUseCase(ref.watch(cartRepositoryProvider));
    });

// 7. Remove Cart Item Use Case Provider
final removeCartItemUseCaseProvider = Provider<RemoveCartItemUseCase>((ref) {
  return RemoveCartItemUseCase(ref.watch(cartRepositoryProvider));
});

// 8. Clear Cart Use Case Provider
final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
});
