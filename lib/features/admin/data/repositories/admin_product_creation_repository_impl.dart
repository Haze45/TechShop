import 'dart:typed_data';

import '../../domain/repositories/admin_product_creation_repository.dart';
import '../datasources/admin_product_creation_datasource.dart';

class AdminProductCreationRepositoryImpl
    implements AdminProductCreationRepository {
  final AdminProductCreationDataSource dataSource;

  AdminProductCreationRepositoryImpl(this.dataSource);

  @override
  Future<String> createProduct({
    required int categoryId,
    required int brandId,
    required String name,
    required String slug,
    required String sku,
    String? description,
    required double price,
    double? compareAtPrice,
    required int stockQuantity,
    required Map<String, dynamic> specifications,
    required bool isActive,
    required bool isFeatured,
  }) {
    return dataSource.createProduct(
      categoryId: categoryId,
      brandId: brandId,
      name: name,
      slug: slug,
      sku: sku,
      description: description,
      price: price,
      compareAtPrice: compareAtPrice,
      stockQuantity: stockQuantity,
      specifications: specifications,
      isActive: isActive,
      isFeatured: isFeatured,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() {
    return dataSource.getCategories();
  }

  @override
  Future<List<Map<String, dynamic>>> getBrands() {
    return dataSource.getBrands();
  }

  @override
  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  }) {
    return dataSource.uploadProductImages(
      productId: productId,
      imageBytes: imageBytes,
      fileNames: fileNames,
    );
  }
}
