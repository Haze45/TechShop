import '../entities/product_review_entity.dart';

abstract class ReviewRepository {
  Future<List<ProductReviewEntity>> getProductReviews(String productId);

  Future<ProductReviewEntity?> getMyReview(String productId);

  Future<String> submitReview({
    required String productId,
    required int rating,
    required String title,
    required String review,
  });

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String title,
    required String review,
  });

  Future<void> deleteReview(String reviewId);
}
