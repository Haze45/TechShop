
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByCategoryUseCase {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  Future<List<ProductEntity>> call({
    required int categoryId,
    int page = 0,
    int limit = 10,
  }) {
    return repository.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }
}
