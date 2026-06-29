import 'package:gloclone/model/notification_model.dart';

class NotificationRepo {
  final List<NotificationModel> _mockDatabase = [
    NotificationModel(
      id: "1",
      title: "Ovulation in 2 days",
      desc: "Your fertile window is starting soon. Take care! 🌸",
      time: "9:00 AM",
      day: "Today",
      badge: "Ovulation",
      icon: "🌸",
      unread: true,
    ),
    NotificationModel(
      id: "2",
      title: "Time to take Iron Supplement",
      desc: "Consistency is the key to better health. 💊",
      time: "10:00 AM",
      day: "Today",
      badge: "Medication",
      icon: "💊",
      unread: true,
    ),
    NotificationModel(
      id: "3",
      title: "Don't forget to log your mood",
      desc: "How are you feeling today? Your Mood Garden misses you! 😊",
      time: "12:00 PM",
      day: "Today",
      badge: "Mood Tracker",
      icon: "😊",
      unread: true,
    ),
    NotificationModel(
      id: "4",
      title: "Derma Visit Tomorrow",
      desc: "You have a dermatology appointment tomorrow at 10:00 AM.",
      time: "8:00 PM",
      day: "Yesterday",
      badge: "Derma Visit",
      icon: "👩‍⚕️",
      unread: false,
    ),
    NotificationModel(
      id: "5",
      title: "Period expected in 3 days",
      desc: "Your period is expected on April 06, 2026.",
      time: "7:00 PM",
      day: "Yesterday",
      badge: "Period",
      icon: "🩸",
      unread: false,
    ),
    NotificationModel(
      id: "6",
      title: "Water Intake Reminder",
      desc: "Log your water intake to hit your hydration goal. 💧",
      time: "3:00 PM",
      day: "Yesterday",
      badge: "Water Tracker",
      icon: "💧",
      unread: false,
    ),
  ];

  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_mockDatabase);
  }

  Future<void> updateReadStatus(String id, bool isRead) async {
    final index = _mockDatabase.indexWhere((element) => element.id == id);
    if (index != -1) {
      _mockDatabase[index].unread = !isRead;
    }
  }

  Future<NotificationModel> saveNotification(NotificationModel notification) async {
    _mockDatabase.insert(0, notification);
    return notification;
  }
}