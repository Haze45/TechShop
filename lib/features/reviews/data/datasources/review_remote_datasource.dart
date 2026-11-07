import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_review_model.dart';

class ReviewRemoteDataSource {
  final SupabaseClient supabase;

  ReviewRemoteDataSource(this.supabase);

  // Get approved reviews for a product
  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    final response = await supabase
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return response.map<ProductReviewModel>((json) {
      return ProductReviewModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Get the current user's review for a product
  Future<ProductReviewModel?> getMyReview(String productId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await supabase
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;

    return ProductReviewModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Submit a review
  Future<String> submitReview({
    required String productId,
    required int rating,
    required String title,
    required String review,
  }) async {
    final response = await supabase.rpc(
      'submit_product_review',
      params: {
        'p_product_id': productId,
        'p_rating': rating,
        'p_title': title,
        'p_review': review,
      },
    );

    return response as String;
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String title,
    required String review,
  }) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('You must be logged in.');
    }

    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5.');
    }

    if (title.trim().isEmpty || review.trim().isEmpty) {
      throw ArgumentError('Title and review cannot be empty.');
    }

    await supabase
        .from('product_reviews')
        .update({
          'rating': rating,
          'title': title.trim(),
          'review': review.trim(),
          'status': 'pending',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reviewId)
        .eq('user_id', userId);
  }

  Future<void> deleteReview(String reviewId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('You must be logged in.');
    }

    await supabase
        .from('product_reviews')
        .delete()
        .eq('id', reviewId)
        .eq('user_id', userId);
  }
}
