import 'product_image_entity.dart';

class ProductEntity {
  final String id;
  final int categoryId;
  final int brandId;

  final String name;
  final String slug;
  final String sku;
  final String? description;

  final double price;
  final double? compareAtPrice;

  final int stockQuantity;

  final Map<String, dynamic> specifications;

  final bool isActive;
  final bool isFeatured;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<ProductImageEntity> images;

  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.brandId,
    required this.name,
    required this.slug,
    required this.sku,
    this.description,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    required this.specifications,
    required this.isActive,
    required this.isFeatured,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
  });

  bool get isInStock => stockQuantity > 0;

  bool get hasDiscount =>
      compareAtPrice != null && compareAtPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0;

    return ((compareAtPrice! - price) / compareAtPrice!) * 100;
  }
}