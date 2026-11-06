import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/entities/product_image_entity.dart';

class AdminProductRemoteDataSource {
  final SupabaseClient supabase;

  AdminProductRemoteDataSource(this.supabase);

  Future<List<ProductModel>> getAllProducts() async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .order('created_at', ascending: false);

    return response.map<ProductModel>((json) {
      return ProductModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  Future<void> updateProduct(ProductEntity product) async {
    await supabase
        .from('products')
        .update({
          'category_id': product.categoryId,
          'brand_id': product.brandId,
          'name': product.name,
          'slug': product.slug,
          'sku': product.sku,
          'description': product.description,
          'price': product.price,
          'compare_at_price': product.compareAtPrice,
          'stock_quantity': product.stockQuantity,
          'specifications': product.specifications,
          'is_active': product.isActive,
          'is_featured': product.isFeatured,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', product.id);
  }

  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  }) async {
    if (imageBytes.length != fileNames.length) {
      throw ArgumentError(
        'Image bytes and file names must have equal lengths.',
      );
    }

    for (var i = 0; i < imageBytes.length; i++) {
      final fileName = fileNames[i];

      final extension = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';

      final contentType = switch (extension) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => throw ArgumentError('Unsupported image format: $extension'),
      };

      final storagePath =
          '$productId/${DateTime.now().microsecondsSinceEpoch}_$i.$extension';

      await supabase.storage
          .from('product-images')
          .uploadBinary(
            storagePath,
            imageBytes[i],
            fileOptions: FileOptions(contentType: contentType),
          );

      final imageUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(storagePath);

      await supabase.from('product_images').insert({
        'product_id': productId,
        'image_url': imageUrl,
        'alt_text': fileName,
        'display_order': i,
        'is_primary': false,
      });
    }
  }

  Future<void> deleteProductImage(ProductImageEntity image) async {
    final uri = Uri.parse(image.imageUrl);
    final pathSegments = uri.pathSegments;

    final bucketIndex = pathSegments.indexOf('product-images');

    if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
      throw Exception('Invalid product image URL.');
    }

    final storagePath = pathSegments.skip(bucketIndex + 1).join('/');

    // Delete the file from Supabase Storage.
    await supabase.storage.from('product-images').remove([storagePath]);

    // Delete the corresponding database record.
    await supabase
        .from('product_images')
        .delete()
        .eq('id', image.id)
        .eq('product_id', image.productId);
  }
}
