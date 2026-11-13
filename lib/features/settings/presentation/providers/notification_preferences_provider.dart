import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/notification_preferences_remote_datasource.dart';
import '../../data/repositories/notification_preferences_repository_impl.dart';
import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_preferences_repository.dart';

final notificationPreferencesDataSourceProvider =
    Provider<NotificationPreferencesRemoteDataSource>((ref) {
      return NotificationPreferencesRemoteDataSource(
        ref.watch(supabaseProvider),
      );
    });

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
      return NotificationPreferencesRepositoryImpl(
        ref.watch(notificationPreferencesDataSourceProvider),
      );
    });

final notificationPreferencesProvider =
    FutureProvider<NotificationPreferencesEntity>((ref) {
      return ref
          .watch(notificationPreferencesRepositoryProvider)
          .getPreferences();
    });
