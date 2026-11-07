import '../../../reviews/domain/entities/product_review_entity.dart';

abstract class AdminReviewRepository {
  Future<List<ProductReviewEntity>> getReviews({String? status});

  Future<void> updateReviewStatus({
    required String reviewId,
    required String status,
  });

  Future<void> deleteReview(String reviewId);
}
