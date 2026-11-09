import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/support_message_model.dart';
import '../models/support_ticket_model.dart';

class SupportRemoteDataSource {
  final SupabaseClient supabase;

  SupportRemoteDataSource(this.supabase);

  // Create a support ticket.
  Future<SupportTicketModel> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
    String? orderId,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await supabase
        .from('support_tickets')
        .insert({
          'user_id': user.id,
          'order_id': orderId,
          'subject': subject,
          'description': description,
          'category': category,
          'priority': priority,
        })
        .select()
        .single();

    return SupportTicketModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Fetch all tickets belonging to the current user.
  Future<List<SupportTicketModel>> getMyTickets() async {
    final response = await supabase
        .from('support_tickets')
        .select()
        .order('created_at', ascending: false);

    return response.map<SupportTicketModel>((json) {
      return SupportTicketModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Fetch a particular ticket.
  Future<SupportTicketModel> getTicketById(String ticketId) async {
    final response = await supabase
        .from('support_tickets')
        .select()
        .eq('id', ticketId)
        .single();

    return SupportTicketModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<SupportMessageModel>> getTicketMessages(String ticketId) async {
    final response = await supabase
        .from('ticket_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return response
        .map<SupportMessageModel>(
          (json) =>
              SupportMessageModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  Future<void> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    await supabase.rpc(
      'send_support_message',
      params: {'p_ticket_id': ticketId, 'p_message': message},
    );
  }

  Future<List<SupportTicketModel>> getAllSupportTickets() async {
    final response = await supabase
        .from('support_tickets')
        .select()
        .order('updated_at', ascending: false);

    return response
        .map<SupportTicketModel>(
          (json) =>
              SupportTicketModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) async {
    await supabase
        .from('support_tickets')
        .update({
          'status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', ticketId);
  }

  Stream<List<SupportMessageModel>> watchTicketMessages(String ticketId) {
    return supabase
        .from('ticket_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .map(
          (rows) => rows
              .map(
                (json) => SupportMessageModel.fromJson(
                  Map<String, dynamic>.from(json),
                ),
              )
              .toList(),
        );
  }
}
