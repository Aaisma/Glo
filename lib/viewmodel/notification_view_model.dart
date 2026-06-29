import 'package:flutter/material.dart';
import 'package:gloclone/model/notification_model.dart';
import 'package:gloclone/repo/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _repository;

  String _selectedTab = "All";
  List<NotificationModel> _allNotifications = [];
  bool _isLoading = false;

  NotificationViewModel(this._repository);

  String get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;

  List<NotificationModel> get filteredNotifications {
    if (_selectedTab == "Unread") {
      return _allNotifications.where((item) => item.unread == true).toList();
    }
    if (_selectedTab == "Read") {
      return _allNotifications.where((item) => item.unread == false).toList();
    }
    return List.from(_allNotifications);
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allNotifications = await _repository.fetchNotifications();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _allNotifications.indexWhere((element) => element.id == id);
    if (index != -1 && _allNotifications[index].unread) {
      _allNotifications[index].unread = false;
      notifyListeners();
      await _repository.updateReadStatus(id, true);
    }
  }

  Future<void> createNotification({
    required String title,
    required String desc,
    required String badge,
    required String icon,
  }) async {
    final newNotification = NotificationModel(
      id: "",
      title: title,
      desc: desc,
      time: "Just Now",
      day: "Today",
      badge: badge,
      icon: icon,
      unread: true,
    );

    _allNotifications.insert(0, newNotification);
    notifyListeners();
    await _repository.saveNotification(newNotification);
  }
}