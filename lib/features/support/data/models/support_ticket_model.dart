import '../../domain/entities/support_ticket_entity.dart';

class SupportTicketModel extends SupportTicketEntity {
  const SupportTicketModel({
    required super.id,
    required super.userId,
    super.orderId,
    required super.subject,
    required super.description,
    required super.category,
    required super.priority,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      orderId: json['order_id'] as String?,
      subject: json['subject'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
