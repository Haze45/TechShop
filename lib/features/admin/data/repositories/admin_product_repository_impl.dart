import '../../domain/repositories/admin_product_repository.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../datasources/admin_product_remote_datasource.dart';

class AdminProductRepositoryImpl implements AdminProductRepository {
  final AdminProductRemoteDataSource remoteDataSource;

  AdminProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getAllProducts() {
    return remoteDataSource.getAllProducts();
  }
}
