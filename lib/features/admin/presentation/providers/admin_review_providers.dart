import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../reviews/domain/entities/product_review_entity.dart';
import '../../data/datasources/admin_review_remote_datasource.dart';
import '../../data/repositories/admin_review_repository_impl.dart';
import '../../domain/repositories/admin_review_repository.dart';

final adminReviewDataSourceProvider = Provider<AdminReviewRemoteDataSource>((
  ref,
) {
  return AdminReviewRemoteDataSource(Supabase.instance.client);
});

final adminReviewRepositoryProvider = Provider<AdminReviewRepository>((ref) {
  return AdminReviewRepositoryImpl(ref.watch(adminReviewDataSourceProvider));
});

final adminReviewsProvider =
    FutureProvider.family<List<ProductReviewEntity>, String>((ref, status) {
      return ref
          .watch(adminReviewRepositoryProvider)
          .getReviews(status: status);
    });
