import 'package:glo/model/notification_model.dart';

abstract class NotificationRepo {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> addNotification({
    required String title,
    required String desc,
    required String badge,
    required String icon,
  });

  Future<void> updateNotificationReadStatus(String id, bool isRead);

  Future<void> markAllAsRead();

  Future<void> clearAll();
}
