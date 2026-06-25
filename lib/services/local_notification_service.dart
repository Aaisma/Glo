import 'package:Gloclone/services/notification_service.dart';
import 'package:Gloclone/models/notification_model.dart';

class LocalNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Initialize flutter_local_notifications settings here
  }

  @override
  Future<void> showNotification(NotificationModel notification) async {
    // Logic to trigger local alarms or periodic alerts (e.g. water reminders)
  }
}