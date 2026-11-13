import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  });

  Future<List<ProductEntity>> getFeaturedProducts({int limit = 10});

  Future<ProductEntity?> getProductById(String productId);

  Future<List<ProductEntity>> getProductsByCategory({
    required int categoryId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  });

  Future<List<ProductEntity>> getProductsByBrand({
    required int brandId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  });

  Future<List<ProductEntity>> searchProducts(
    String query, {
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  });

  Future<List<ProductEntity>> getRelatedProducts({
    required int categoryId,
    required String excludeProductId,
    int limit = 10,
  });

  Future<List<Map<String, dynamic>>> getCategories();

  Future<List<Map<String, dynamic>>> getBrands();
}
