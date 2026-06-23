import '../models/notification_model.dart';
import '../services/firebase_notification_service.dart';
import '../services/local_notification_service.dart';
import 'notification_repository.dart';

class NotificationRepositoryImpl
    implements NotificationRepository {
  final FirebaseNotificationService firebaseService;
  final LocalNotificationService localService;

  NotificationRepositoryImpl({
    required this.firebaseService,
    required this.localService,
  });

  @override
  Future<List<AppNotification>>
  getNotifications() async {
    return await firebaseService
        .getNotifications();
  }

  @override
  Future<void> addNotification(
      AppNotification notification,
      ) async {
    await firebaseService
        .saveNotification(notification);

    await localService
        .showNotification(
      notification,
    );
  }

  @override
  Future<void> markAsRead(
      String notificationId,
      ) async {
    await firebaseService
        .markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await firebaseService.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(
      String notificationId,
      ) async {
    await firebaseService
        .deleteNotification(
      notificationId,
    );
  }

  @override
  Future<void>
  clearAllNotifications() async {
    await firebaseService
        .clearAllNotifications();
  }
}