import 'dart:typed_data';

abstract class AdminProductCreationRepository {
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
  });

  Future<List<Map<String, dynamic>>> getCategories();

  Future<List<Map<String, dynamic>>> getBrands();

  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  });
}
