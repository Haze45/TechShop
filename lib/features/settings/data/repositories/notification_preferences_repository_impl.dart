import '../../domain/entities/notification_preferences_entity.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../datasources/notification_preferences_remote_datasource.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  final NotificationPreferencesRemoteDataSource remoteDataSource;

  NotificationPreferencesRepositoryImpl(this.remoteDataSource);

  @override
  Future<NotificationPreferencesEntity> getPreferences() {
    return remoteDataSource.getPreferences();
  }

  @override
  Future<void> updateOrderNotifications(bool enabled) {
    return remoteDataSource.updateOrderNotifications(enabled);
  }
}
