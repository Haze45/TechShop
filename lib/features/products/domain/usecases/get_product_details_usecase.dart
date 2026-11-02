import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase {
  final ProductRepository repository;

  GetProductDetailsUseCase(this.repository);

  Future<ProductEntity?> call(String productId) {
    return repository.getProductById(productId);
  }
}
