
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<ProductEntity>> call(String query, {String sortOption = 'newest'}) {
    return repository.searchProducts(query,sortOption: sortOption,);
  }
}
