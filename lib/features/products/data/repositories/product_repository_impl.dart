import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts({
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return remoteDataSource.getProducts(page: page, limit: limit);
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts({int limit = 10}) {
    return remoteDataSource.getFeaturedProducts(limit: limit);
  }

  @override
  Future<ProductEntity?> getProductById(String productId) {
    return remoteDataSource.getProductById(productId);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory({
    required int categoryId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return remoteDataSource.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ProductEntity>> getProductsByBrand({
    required int brandId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) {
    return remoteDataSource.getProductsByBrand(
      brandId: brandId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<List<ProductEntity>> searchProducts(
    String query, {
    String sortOption = 'newest',
  }) {
    return remoteDataSource.searchProducts(query);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() {
    return remoteDataSource.getCategories();
  }

  @override
  Future<List<Map<String, dynamic>>> getBrands() {
    return remoteDataSource.getBrands();
  }
}
