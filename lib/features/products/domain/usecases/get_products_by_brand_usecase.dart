
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByBrandUseCase {
  final ProductRepository repository;

  GetProductsByBrandUseCase(this.repository);

  Future<List<ProductEntity>> call({
    required int brandId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return repository.getProductsByBrand(
      brandId: brandId,
      page: page,
      limit: limit,
      sortOption: sortOption,
    );
  }
}
