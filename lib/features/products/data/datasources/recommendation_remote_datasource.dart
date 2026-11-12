import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class RecommendationRemoteDataSource {
  final SupabaseClient supabase;

  RecommendationRemoteDataSource(this.supabase);

  Future<List<ProductModel>> getPersonalizedRecommendations({
    int limit = 10,
  }) async {
    final user = supabase.auth.currentUser;

    // Guest users receive popular products.
    if (user == null) {
      return getFallbackRecommendations(limit: limit);
    }

    // Logged-in users receive personalized recommendations.
    final response = await supabase.rpc(
      'get_personalized_product_recommendations',
      params: {'p_limit': limit},
    );

    final recommendedProducts = response as List;

    // If there are no personalized results, use fallback products.
    if (recommendedProducts.isEmpty) {
      return getFallbackRecommendations(limit: limit);
    }

    final productIds = recommendedProducts
        .map((item) => item['id'] as String)
        .toList();

    // Fetch product details and images.
    final productsResponse = await supabase
        .from('products')
        .select('*, product_images(*)')
        .inFilter('id', productIds);

    final productsById = {
      for (final item in productsResponse)
        item['id'] as String: ProductModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
    };

    // Preserve recommendation ranking.
    return productIds
        .where((id) => productsById.containsKey(id))
        .map((id) => productsById[id]!)
        .toList();
  }

  // Fallback for guest users and customers without recommendations.
  Future<List<ProductModel>> getFallbackRecommendations({
    int limit = 10,
  }) async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('is_active', true)
        .gt('stock_quantity', 0)
        .order('is_featured', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit.clamp(1, 20));

    return response.map<ProductModel>((json) {
      return ProductModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }
}
