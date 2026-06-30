import 'package:gloclone/model/notification_model.dart';

class NotificationRepo {
  final List<NotificationModel> _mockDatabase = [];

  Future<List<NotificationModel>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockDatabase);
  }

  Future<void> addNotification({
    required String title,
    required String desc,
    required String badge,
    required String icon,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final newNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      desc: desc,
      badge: badge,
      icon: icon,
      unread: true,
      day: "Today",
      time: "Just now",
      createdAt: DateTime.now(),
    );

    _mockDatabase.insert(0, newNotification);
  }

  Future<void> updateNotificationReadStatus(String id, bool isRead) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockDatabase.indexWhere((note) => note.id == id);
    if (index != -1) {
      _mockDatabase[index] = NotificationModel(
        id: _mockDatabase[index].id,
        title: _mockDatabase[index].title,
        desc: _mockDatabase[index].desc,
        badge: _mockDatabase[index].badge,
        icon: _mockDatabase[index].icon,
        unread: !isRead,
        day: _mockDatabase[index].day,
        time: _mockDatabase[index].time,
        createdAt: _mockDatabase[index].createdAt,
      );
    }
  }
}