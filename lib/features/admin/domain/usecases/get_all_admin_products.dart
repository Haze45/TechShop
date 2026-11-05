import '../repositories/admin_product_repository.dart';
import '../../../products/domain/entities/product_entity.dart';

class GetAllAdminProducts {
  final AdminProductRepository repository;

  GetAllAdminProducts(this.repository);

  Future<List<ProductEntity>> call() {
    return repository.getAllProducts();
  }
}
