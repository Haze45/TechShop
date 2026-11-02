
import '../../domain/entities/product_entity.dart';
import 'product_image_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.categoryId,
    required super.brandId,
    required super.name,
    required super.slug,
    required super.sku,
    super.description,
    required super.price,
    super.compareAtPrice,
    required super.stockQuantity,
    required super.specifications,
    required super.isActive,
    required super.isFeatured,
    required super.createdAt,
    required super.updatedAt,
    super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imageList = json['product_images'] as List<dynamic>? ?? [];

    return ProductModel(
      id: json['id'] as String,
      categoryId: (json['category_id'] as num).toInt(),
      brandId: (json['brand_id'] as num).toInt(),

      name: json['name'] as String,
      slug: json['slug'] as String,
      sku: json['sku'] as String,

      description: json['description'] as String?,

      price: (json['price'] as num).toDouble(),

      compareAtPrice:
      (json['compare_at_price'] as num?)?.toDouble(),

      stockQuantity:
      (json['stock_quantity'] as num?)?.toInt() ?? 0,

      specifications:
      Map<String, dynamic>.from(
        json['specifications'] as Map? ?? {},
      ),

      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),

      images: imageList
          .map(
            (image) => ProductImageModel.fromJson(
          Map<String, dynamic>.from(image as Map),
        ),
      )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'product_images': images
          .map((image) => ProductImageModel(
        id: image.id,
        productId: image.productId,
        imageUrl: image.imageUrl,
        altText: image.altText,
        displayOrder: image.displayOrder,
        isPrimary: image.isPrimary,
      ).toJson())
          .toList(),
    };
  }
}
