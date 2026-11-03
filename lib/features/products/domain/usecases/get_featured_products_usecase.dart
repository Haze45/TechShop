import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetFeaturedProductsUseCase {
  final ProductRepository repository;

  GetFeaturedProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({int limit = 10}) {
    return repository.getFeaturedProducts(limit: limit);
  }
}
