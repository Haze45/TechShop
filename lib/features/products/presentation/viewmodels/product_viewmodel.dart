import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import 'product_state.dart';

class ProductViewModel extends AsyncNotifier<ProductState> {
  static const int pageSize = 10;

  @override
  Future<ProductState> build() async {
    // Load initial product data.
    final products = await ref.read(getProductsUseCaseProvider)(
      page: 0,
      limit: pageSize,
    );

    final featuredProducts = await ref.read(getFeaturedProductsUseCaseProvider)(
      limit: 10,
    );

    final categories = await ref.read(getCategoriesUseCaseProvider)();

    final brands = await ref.read(getBrandsUseCaseProvider)();

    return ProductState(
      products: products,
      featuredProducts: featuredProducts,
      categories: categories,
      brands: brands,
      currentPage: 0,
      hasMore: products.length == pageSize,
    );
  }

  // Get the current ProductState.
  ProductState get _currentState {
    return state.value ?? const ProductState();
  }

  // Load products according to the active filter.
  Future<List<ProductEntity>> _fetchProducts({
    required int page,
    required ProductState current,
  }) {
    final query = current.searchQuery.trim();

    final sortOption = current.sortOption.name;

    if (query.isNotEmpty) {
      return ref.read(searchProductsUseCaseProvider)(
        query,
        sortOption: sortOption,
      );
    }

    if (current.selectedCategoryId != null) {
      return ref.read(getProductsByCategoryUseCaseProvider)(
        categoryId: current.selectedCategoryId!,
        page: page,
        limit: pageSize,
        sortOption: sortOption,
      );
    }

    if (current.selectedBrandId != null) {
      return ref.read(getProductsByBrandUseCaseProvider)(
        brandId: current.selectedBrandId!,
        page: page,
        limit: pageSize,
        sortOption: sortOption,
      );
    }

    return ref.read(getProductsUseCaseProvider)(
      page: page,
      limit: pageSize,
      sortOption: sortOption,
    );
  }

  // Refresh products.
  Future<void> loadProducts() async {
    final current = _currentState;

    state = const AsyncLoading();

    try {
      final products = await _fetchProducts(page: 0, current: current);

      state = AsyncData(
        current.copyWith(
          products: products,
          currentPage: 0,
          hasMore: products.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Filter products by category.
  Future<void> filterByCategory(int categoryId) async {
    final current = _currentState.copyWith(
      selectedCategoryId: categoryId,
      clearBrand: true,
      searchQuery: '',
    );

    state = const AsyncLoading();

    try {
      final products = await _fetchProducts(page: 0, current: current);

      state = AsyncData(
        current.copyWith(
          products: products,
          currentPage: 0,
          hasMore: products.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Filter products by brand.
  Future<void> filterByBrand(int? brandId) async {
    final current = _currentState.copyWith(
      selectedBrandId: brandId,
      clearBrand: brandId == null,
      clearCategory: true,
      searchQuery: '',
    );

    state = const AsyncLoading();

    try {
      final products = await _fetchProducts(page: 0, current: current);

      state = AsyncData(
        current.copyWith(
          products: products,
          currentPage: 0,
          hasMore: products.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Search products.
  Future<void> searchProducts(String query) async {
    final current = _currentState.copyWith(
      searchQuery: query,
      clearCategory: true,
      clearBrand: true,
    );

    state = const AsyncLoading();

    try {
      final products = await _fetchProducts(page: 0, current: current);

      state = AsyncData(
        current.copyWith(products: products, currentPage: 0, hasMore: false),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Remove all active filters.
  Future<void> clearFilters() async {
    final current = _currentState.copyWith(
      clearCategory: true,
      clearBrand: true,
      searchQuery: '',
    );

    state = const AsyncLoading();

    try {
      final products = await ref.read(getProductsUseCaseProvider)(
        page: 0,
        limit: pageSize,
      );

      state = AsyncData(
        current.copyWith(
          products: products,
          currentPage: 0,
          hasMore: products.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Load the next page of products.
  Future<void> loadMoreProducts() async {
    final current = _currentState;

    if (current.isLoadingMore || !current.hasMore) {
      return;
    }

    // Search currently returns all matching results without pagination.
    if (current.searchQuery.trim().isNotEmpty) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;

      final newProducts = await _fetchProducts(
        page: nextPage,
        current: current,
      );

      state = AsyncData(
        current.copyWith(
          products: [...current.products, ...newProducts],
          currentPage: nextPage,
          hasMore: newProducts.length == pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncData(current.copyWith(isLoadingMore: false));

      // Keep the existing product list and expose the error to the caller.
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> sortProducts(ProductSortOption option) async {
    final current = _currentState.copyWith(sortOption: option);

    state = const AsyncLoading();

    try {
      final products = await _fetchProducts(page: 0, current: current);

      state = AsyncData(
        current.copyWith(
          products: products,
          currentPage: 0,
          hasMore: products.length == pageSize,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  // Get a single product's details.
  Future<ProductEntity?> getProductDetails(String productId) {
    return ref.read(getProductDetailsUseCaseProvider)(productId);
  }
}
