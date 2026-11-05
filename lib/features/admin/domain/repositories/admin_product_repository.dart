import '../../../products/domain/entities/product_entity.dart';

abstract class AdminProductRepository {
  Future<List<ProductEntity>> getAllProducts();
}
