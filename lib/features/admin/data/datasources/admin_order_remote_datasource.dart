import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../orders/data/models/order_model.dart';

class AdminOrderRemoteDataSource {
  final SupabaseClient supabase;

  AdminOrderRemoteDataSource(this.supabase);

  // Fetch all customer orders for the admin.
  Future<List<OrderModel>> getAllOrders() async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .order('placed_at', ascending: false);

    return response.map<OrderModel>((json) {
      return OrderModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Fetch a particular order using its ID.
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();

    return OrderModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Update order status through the secure Supabase RPC.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await supabase.rpc(
      'admin_update_order_status',
      params: {'p_order_id': orderId, 'p_new_status': newStatus},
    );
  }

  Future<void> cancelOrder(String orderId) async {
    await supabase.rpc('admin_cancel_order', params: {'p_order_id': orderId});
  }
}
