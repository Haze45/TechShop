import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/data/models/product_model.dart';

class AdminProductRemoteDataSource {
  final SupabaseClient supabase;

  AdminProductRemoteDataSource(this.supabase);

  Future<List<ProductModel>> getAllProducts() async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .order('created_at', ascending: false);

    return response.map<ProductModel>((json) {
      return ProductModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }
}
