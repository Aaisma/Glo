import 'package:Gloclone/services/notification_service.dart';
import 'package:Gloclone/models/notification_model.dart';

class FirebaseNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Initialize Firebase Messaging handlers here
  }

  @override
  Future<void> showNotification(NotificationModel notification) async {
    // Logic to handle incoming foreground FCM push payloads
  }
}