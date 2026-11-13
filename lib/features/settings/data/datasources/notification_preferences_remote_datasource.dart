import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_preferences_model.dart';

class NotificationPreferencesRemoteDataSource {
  final SupabaseClient supabase;

  NotificationPreferencesRemoteDataSource(this.supabase);

  Future<NotificationPreferencesModel> getPreferences() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await supabase
        .from('user_notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    // No saved preferences means notifications are enabled by default.
    if (response == null) {
      return const NotificationPreferencesModel(orderUpdatesEnabled: true);
    }

    return NotificationPreferencesModel.fromJson(response);
  }

  Future<void> updateOrderNotifications(bool enabled) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not authenticated.');
    }

    final preferences = NotificationPreferencesModel(
      orderUpdatesEnabled: enabled,
    );

    await supabase
        .from('user_notification_preferences')
        .upsert(preferences.toJson(userId), onConflict: 'user_id');
  }
}
