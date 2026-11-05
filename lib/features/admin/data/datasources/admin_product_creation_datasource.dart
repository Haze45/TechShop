import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProductCreationDataSource {
  final SupabaseClient supabase;

  AdminProductCreationDataSource(this.supabase);

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
  }) async {
    final response = await supabase
        .from('products')
        .insert({
          'category_id': categoryId,
          'brand_id': brandId,
          'name': name,
          'slug': slug,
          'sku': sku,
          'description': description,
          'price': price,
          'compare_at_price': compareAtPrice,
          'stock_quantity': stockQuantity,
          'specifications': specifications,
          'is_active': isActive,
          'is_featured': isFeatured,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await supabase.from('categories').select().order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getBrands() async {
    final response = await supabase.from('brands').select().order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> uploadProductImages({
    required String productId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  }) async {
    for (var i = 0; i < imageBytes.length; i++) {
      final fileName = fileNames[i];
      final extension = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'jpg';

      final storagePath =
          '$productId/${DateTime.now().microsecondsSinceEpoch}_$i.$extension';

      final contentType = switch (extension) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'gif' => 'image/gif',
        _ => 'image/jpeg',
      };

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
        'is_primary': i == 0,
      });
    }
  }
}
