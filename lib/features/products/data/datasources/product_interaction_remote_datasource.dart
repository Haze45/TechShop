import 'package:supabase_flutter/supabase_flutter.dart';

class ProductInteractionRemoteDataSource {
  final SupabaseClient supabase;

  ProductInteractionRemoteDataSource(this.supabase);

  Future<void> recordInteraction({
    required String productId,
    required String interactionType,
  }) async {
    await supabase.rpc(
      'record_product_interaction',
      params: {
        'p_product_id': productId,
        'p_interaction_type': interactionType,
      },
    );
  }
}
