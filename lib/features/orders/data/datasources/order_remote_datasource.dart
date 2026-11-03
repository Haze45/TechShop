import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';

class OrderRemoteDataSource {
  final SupabaseClient supabase;

  OrderRemoteDataSource(this.supabase);

  // =========================================
  // GET ALL ORDERS FOR A USER
  // =========================================

  Future<List<OrderModel>> getOrders(String userId) async {
    final response = await supabase
        .from('orders')
        .select('''
          *,
          order_items(*)
        ''')
        .eq('user_id', userId)
        .order('placed_at', ascending: false);

    return response.map((json) => OrderModel.fromJson(json)).toList();
  }

  // =========================================
  // GET ORDER BY ID
  // =========================================

  Future<OrderModel?> getOrderById({
    required String orderId,
    required String userId,
  }) async {
    final response = await supabase
        .from('orders')
        .select('''
          *,
          order_items(*)
        ''')
        .eq('id', orderId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return OrderModel.fromJson(response);
  }
}
