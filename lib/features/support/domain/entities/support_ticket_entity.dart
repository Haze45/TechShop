class SupportTicketEntity {
  final String id;
  final String userId;
  final String? orderId;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicketEntity({
    required this.id,
    required this.userId,
    this.orderId,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}