import '../../domain/entities/product_review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductReviewEntity>> getProductReviews(String productId) {
    return remoteDataSource.getProductReviews(productId);
  }

  @override
  Future<ProductReviewEntity?> getMyReview(String productId) {
    return remoteDataSource.getMyReview(productId);
  }

  @override
  Future<String> submitReview({
    required String productId,
    required int rating,
    required String title,
    required String review,
  }) {
    return remoteDataSource.submitReview(
      productId: productId,
      rating: rating,
      title: title,
      review: review,
    );
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String title,
    required String review,
  }) {
    return remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      title: title,
      review: review,
    );
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return remoteDataSource.deleteReview(reviewId);
  }
}
