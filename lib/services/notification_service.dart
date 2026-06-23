abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getDeviceToken();
  void listenToIncomingNotifications(Function(Map<String, dynamic>) onNotificationReceived);
}