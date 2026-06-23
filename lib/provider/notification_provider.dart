import 'package:flutter/material.dart';
import 'package:Glo/models/notification_model.dart';
import 'package:Glo/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  String _activeTab = 'All';

  List<NotificationModel> get notifications => _notifications;
  String get activeTab => _activeTab;

  Future<void> loadNotifications() async {
    _notifications = await _repository.fetchNotificationsFromBackend();
    notifyListeners();
  }

  void setActiveTab(String tabName) {
    _activeTab = tabName;
    notifyListeners();
  }

  void toggleReadState(int id) {
    final index = _notifications.indexWhere((element) => element.id == id);
    if (index != -1) {
      _notifications[index].isUnread = !_notifications[index].isUnread;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var item in _notifications) {
      item.isUnread = false;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  List<NotificationModel> get filteredNotifications {
    if (_activeTab == 'Unread') return _notifications.where((e) => e.isUnread).toList();
    if (_activeTab == 'Read') return _notifications.where((e) => !e.isUnread).toList();
    return _notifications;
  }
}