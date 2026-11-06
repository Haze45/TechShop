import 'dart:typed_data';

import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/entities/product_image_entity.dart';

abstract class AdminProductRepository {
  Future<List<ProductEntity>> getAllProducts();
  Future<void> updateProduct(ProductEntity product);
  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  });

  Future<void> deleteProductImage(ProductImageEntity image);
}
