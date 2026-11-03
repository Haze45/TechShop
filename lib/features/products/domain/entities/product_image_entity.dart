class ProductImageEntity {
  final String id;
  final String productId;
  final String imageUrl;
  final String? altText;
  final int displayOrder;
  final bool isPrimary;

  const ProductImageEntity({
    required this.id,
    required this.productId,
    required this.imageUrl,
    this.altText,
    required this.displayOrder,
    required this.isPrimary,
  });
}
