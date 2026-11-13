import '../../domain/entities/notification_preferences_entity.dart';

class NotificationPreferencesModel extends NotificationPreferencesEntity {
  const NotificationPreferencesModel({required super.orderUpdatesEnabled});

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      orderUpdatesEnabled: json['order_updates_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'order_updates_enabled': orderUpdatesEnabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
