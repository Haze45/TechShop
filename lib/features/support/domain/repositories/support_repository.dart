import '../entities/support_message_entity.dart';
import '../entities/support_ticket_entity.dart';

abstract class SupportRepository {
  Future<SupportTicketEntity> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
    String? orderId,
  });

  Future<List<SupportTicketEntity>> getMyTickets();

  Future<SupportTicketEntity> getTicketById(String ticketId);

  Future<List<SupportMessageEntity>> getTicketMessages(String ticketId);

  Future<void> sendMessage({required String ticketId, required String message});

  Future<List<SupportTicketEntity>> getAllSupportTickets();

  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  });

  Stream<List<SupportMessageEntity>> watchTicketMessages(String ticketId);
}
