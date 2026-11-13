import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetRelatedProductsUseCase {
  final ProductRepository repository;

  GetRelatedProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    required int categoryId,
    required String excludeProductId,
    int limit = 10,
  }) {
    return repository.getRelatedProducts(
      categoryId: categoryId,
      excludeProductId: excludeProductId,
      limit: limit,
    );
  }
}
