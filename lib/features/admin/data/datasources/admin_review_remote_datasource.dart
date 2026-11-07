import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../reviews/data/models/product_review_model.dart';

class AdminReviewRemoteDataSource {
  final SupabaseClient supabase;

  AdminReviewRemoteDataSource(this.supabase);

  Future<List<ProductReviewModel>> getReviews({String? status}) async {
    final response = status == null || status == 'all'
        ? await supabase
              .from('product_reviews')
              .select()
              .order('created_at', ascending: false)
        : await supabase
              .from('product_reviews')
              .select()
              .eq('status', status)
              .order('created_at', ascending: false);

    return response.map<ProductReviewModel>((json) {
      return ProductReviewModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  Future<void> updateReviewStatus({
    required String reviewId,
    required String status,
  }) async {
    if (!['approved', 'rejected'].contains(status)) {
      throw ArgumentError('Invalid review status.');
    }

    await supabase
        .from('product_reviews')
        .update({
          'status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reviewId);
  }

  Future<void> deleteReview(String reviewId) async {
    await supabase.from('product_reviews').delete().eq('id', reviewId);
  }
}
