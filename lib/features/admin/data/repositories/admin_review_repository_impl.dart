import '../../../reviews/domain/entities/product_review_entity.dart';
import '../../domain/repositories/admin_review_repository.dart';
import '../datasources/admin_review_remote_datasource.dart';

class AdminReviewRepositoryImpl implements AdminReviewRepository {
  final AdminReviewRemoteDataSource remoteDataSource;

  AdminReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductReviewEntity>> getReviews({String? status}) {
    return remoteDataSource.getReviews(status: status);
  }

  @override
  Future<void> updateReviewStatus({
    required String reviewId,
    required String status,
  }) {
    return remoteDataSource.updateReviewStatus(
      reviewId: reviewId,
      status: status,
    );
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return remoteDataSource.deleteReview(reviewId);
  }
}
