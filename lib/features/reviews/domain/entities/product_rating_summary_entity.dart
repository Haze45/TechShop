class ProductRatingSummaryEntity {
  final String productId;
  final double averageRating;
  final int reviewCount;

  const ProductRatingSummaryEntity({
    required this.productId,
    required this.averageRating,
    required this.reviewCount,
  });
}
