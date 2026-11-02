
import '../../domain/entities/product_entity.dart';

class ProductState {
  final List<ProductEntity> products;
  final List<ProductEntity> featuredProducts;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> brands;

  final int? selectedCategoryId;
  final int? selectedBrandId;
  final String searchQuery;

  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const ProductState({
    this.products = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.brands = const [],
    this.selectedCategoryId,
    this.selectedBrandId,
    this.searchQuery = '',
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ProductState copyWith({
    List<ProductEntity>? products,
    List<ProductEntity>? featuredProducts,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? brands,
    int? selectedCategoryId,
    int? selectedBrandId,
    String? searchQuery,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCategory = false,
    bool clearBrand = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      selectedCategoryId: clearCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      selectedBrandId:
      clearBrand ? null : selectedBrandId ?? this.selectedBrandId,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
