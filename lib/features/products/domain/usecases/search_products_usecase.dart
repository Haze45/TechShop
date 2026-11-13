import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(
    String query, {
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return repository.searchProducts(
      query,
      page: page,
      limit: limit,
      sortOption: sortOption,
    );
  }
}
