import '../../domain/entities/support_message_entity.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_datasource.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource remoteDataSource;

  SupportRepositoryImpl(this.remoteDataSource);

  @override
  Future<SupportTicketEntity> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
    String? orderId,
  }) {
    return remoteDataSource.createTicket(
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      orderId: orderId,
    );
  }

  @override
  Future<List<SupportTicketEntity>> getMyTickets() {
    return remoteDataSource.getMyTickets();
  }

  @override
  Future<SupportTicketEntity> getTicketById(String ticketId) {
    return remoteDataSource.getTicketById(ticketId);
  }

  @override
  Future<List<SupportMessageEntity>> getTicketMessages(String ticketId) {
    return remoteDataSource.getTicketMessages(ticketId);
  }

  @override
  Future<void> sendMessage({
    required String ticketId,
    required String message,
  }) {
    return remoteDataSource.sendMessage(ticketId: ticketId, message: message);
  }

  @override
  Future<List<SupportTicketEntity>> getAllSupportTickets() {
    return remoteDataSource.getAllSupportTickets();
  }

  @override
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status,
  }) {
    return remoteDataSource.updateTicketStatus(
      ticketId: ticketId,
      status: status,
    );
  }

  @override
  Stream<List<SupportMessageEntity>> watchTicketMessages(
      String ticketId,
      ) {
    return remoteDataSource.watchTicketMessages(ticketId);
  }
}
