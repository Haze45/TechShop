class SupportMessageEntity {
  final String id;
  final String ticketId;
  final String senderId;
  final String message;
  final bool isAdminReply;
  final DateTime createdAt;

  const SupportMessageEntity({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    required this.isAdminReply,
    required this.createdAt,
  });
}