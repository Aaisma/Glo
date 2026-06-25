import 'package:glo/models/notification_model.dart';
import 'package:glo/services/firebase_notification_service.dart';
import 'package:glo/services/local_notification_service.dart';

/// Abstract contract for the repository
abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications();
  Future<void> addNotification(AppNotification notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAllNotifications();
}

/// Implementation of the repository
class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseNotificationService firebaseService;
  final LocalNotificationService localService;

  NotificationRepositoryImpl({
    required this.firebaseService,
    required this.localService,
  });

  @override
  Future<List<AppNotification>> getNotifications() async {
    return await firebaseService.getNotifications();
  }

  @override
  Future<void> addNotification(AppNotification notification) async {
    await firebaseService.saveNotification(notification);
    await localService.showNotification(notification);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await firebaseService.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await firebaseService.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await firebaseService.deleteNotification(notificationId);
  }

  @override
  Future<void> clearAllNotifications() async {
    await firebaseService.clearAllNotifications();
  }
}
