class ProductReviewEntity {
  final String id;
  final String productId;
  final String userId;
  final int rating;
  final String title;
  final String review;
  final String status;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.title,
    required this.review,
    required this.status,
    required this.isVerifiedPurchase,
    required this.createdAt,
    required this.updatedAt,
  });
}
