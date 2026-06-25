import 'package:glo/models/notification_model.dart';

abstract class NotificationService {
  Future<void> initialize();
  Future<void> showNotification(NotificationModel notification);
}
