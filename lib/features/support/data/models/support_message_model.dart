import '../../domain/entities/support_message_entity.dart';

class SupportMessageModel extends SupportMessageEntity {
  const SupportMessageModel({
    required super.id,
    required super.ticketId,
    required super.senderId,
    required super.message,
    required super.isAdminReply,
    required super.createdAt,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      isAdminReply: json['is_admin_reply'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}