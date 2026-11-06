import 'dart:typed_data';

import '../../../products/domain/entities/product_image_entity.dart';
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

  @override
  Future<void> updateProduct(ProductEntity product) {
    return remoteDataSource.updateProduct(product);
  }

  @override
  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  }) {
    return remoteDataSource.uploadProductImages(
      productId: productId,
      imageBytes: imageBytes,
      fileNames: fileNames,
    );
  }

  @override
  Future<void> deleteProductImage(ProductImageEntity image) {
    return remoteDataSource.deleteProductImage(image);
  }
}
