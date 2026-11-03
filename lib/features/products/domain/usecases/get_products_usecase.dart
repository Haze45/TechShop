import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return repository.getProducts(
      page: page,
      limit: limit,
      sortOption: sortOption,
    );
  }
}
