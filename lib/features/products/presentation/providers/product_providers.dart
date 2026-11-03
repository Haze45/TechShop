import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/get_featured_products_usecase.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import '../../domain/usecases/get_products_by_category_usecase.dart';
import '../../domain/usecases/get_products_by_brand_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../viewmodels/product_state.dart';
import '../viewmodels/product_viewmodel.dart';

// --------------------------------------------------
// Data Source Provider
// --------------------------------------------------

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);

  return ProductRemoteDataSource(supabase);
});

// --------------------------------------------------
// Repository Provider
// --------------------------------------------------

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);

  return ProductRepositoryImpl(remoteDataSource);
});

// --------------------------------------------------
// Use Case Providers
// --------------------------------------------------

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final getFeaturedProductsUseCaseProvider = Provider<GetFeaturedProductsUseCase>(
  (ref) {
    return GetFeaturedProductsUseCase(ref.watch(productRepositoryProvider));
  },
);

final getProductDetailsUseCaseProvider = Provider<GetProductDetailsUseCase>((
  ref,
) {
  return GetProductDetailsUseCase(ref.watch(productRepositoryProvider));
});

final getProductsByCategoryUseCaseProvider =
    Provider<GetProductsByCategoryUseCase>((ref) {
      return GetProductsByCategoryUseCase(ref.watch(productRepositoryProvider));
    });

final getProductsByBrandUseCaseProvider = Provider<GetProductsByBrandUseCase>((
  ref,
) {
  return GetProductsByBrandUseCase(ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(productRepositoryProvider));
});

final getBrandsUseCaseProvider = Provider<GetBrandsUseCase>((ref) {
  return GetBrandsUseCase(ref.watch(productRepositoryProvider));
});

// Product ViewModel Provider
final productViewModelProvider =
    AsyncNotifierProvider<ProductViewModel, ProductState>(ProductViewModel.new);

final productDetailsProvider = FutureProvider.family<ProductEntity?, String>((
  ref,
  productId,
) {
  return ref.watch(getProductDetailsUseCaseProvider)(productId);
});
