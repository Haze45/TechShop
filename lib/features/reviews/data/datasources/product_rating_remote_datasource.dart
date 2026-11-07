import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_rating_summary_model.dart';

class ProductRatingRemoteDataSource {
  final SupabaseClient supabase;

  ProductRatingRemoteDataSource(this.supabase);

  Future<ProductRatingSummaryModel?> getRatingSummary(String productId) async {
    final response = await supabase
        .from('product_review_summaries')
        .select()
        .eq('product_id', productId)
        .maybeSingle();

    if (response == null) return null;

    return ProductRatingSummaryModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}
