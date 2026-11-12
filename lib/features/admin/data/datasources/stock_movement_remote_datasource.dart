import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../products/data/models/product_model.dart';
import '../models/stock_movement_model.dart';

class StockMovementRemoteDataSource {
  final SupabaseClient supabase;

  StockMovementRemoteDataSource(this.supabase);

  // Get all stock movements.
  Future<List<StockMovementModel>> getAllStockMovements() async {
    final response = await supabase
        .from('stock_movements')
        .select()
        .order('created_at', ascending: false);

    return response.map<StockMovementModel>((json) {
      return StockMovementModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Get stock movements for a specific product.
  Future<List<StockMovementModel>> getProductStockMovements(
    String productId,
  ) async {
    final response = await supabase
        .from('stock_movements')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return response.map<StockMovementModel>((json) {
      return StockMovementModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Manually adjust product stock using the secure RPC.
  Future<String> adjustProductStock({
    required String productId,
    required int quantityChange,
    String? reason,
  }) async {
    final response = await supabase.rpc(
      'admin_adjust_product_stock',
      params: {
        'p_product_id': productId,
        'p_quantity_change': quantityChange,
        'p_reason': reason,
      },
    );

    return response as String;
  }

  Future<List<ProductModel>> getInventoryProducts() async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .order('name', ascending: true);

    return response.map<ProductModel>((json) {
      return ProductModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }
}
