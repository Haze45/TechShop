import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/product_rating_remote_datasource.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/product_rating_summary_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/entities/product_review_entity.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  return ReviewRemoteDataSource(Supabase.instance.client);
});

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.read(reviewRemoteDataSourceProvider));
});

final productReviewsProvider =
    FutureProvider.family<List<ProductReviewEntity>, String>((
      ref,
      productId,
    ) async {
      return ref.read(reviewRepositoryProvider).getProductReviews(productId);
    });

final myProductReviewProvider =
    FutureProvider.family<ProductReviewEntity?, String>((ref, productId) async {
      return ref.read(reviewRepositoryProvider).getMyReview(productId);
    });

final productRatingDataSourceProvider = Provider<ProductRatingRemoteDataSource>(
  (ref) {
    return ProductRatingRemoteDataSource(Supabase.instance.client);
  },
);

final productRatingSummaryProvider =
    FutureProvider.family<ProductRatingSummaryEntity?, String>((
      ref,
      productId,
    ) {
      return ref
          .watch(productRatingDataSourceProvider)
          .getRatingSummary(productId);
    });
