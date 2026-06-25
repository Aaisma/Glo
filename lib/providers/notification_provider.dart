import 'package:flutter/material.dart';
import 'package:glo/models/notification_model.dart';
import 'package:glo/repo/notification_repository.dart';

enum NotificationTabFilter { all, unread, read }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  List<NotificationModel> _notifications = [];
  NotificationTabFilter _currentFilter = NotificationTabFilter.all;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  NotificationTabFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get filteredNotifications {
    switch (_currentFilter) {
      case NotificationTabFilter.unread:
        return _notifications.where((n) => !n.isRead).toList();
      case NotificationTabFilter.read:
        return _notifications.where((n) => n.isRead).toList();
      case NotificationTabFilter.all:
      default:
        return _notifications;
    }
  }

  void changeFilter(NotificationTabFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repository.fetchNotifications();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = NotificationModel(
        id: _notifications[index].id,
        title: _notifications[index].title,
        description: _notifications[index].description,
        timestamp: _notifications[index].timestamp,
        type: _notifications[index].type,
        isRead: true,
        typeLabel: _notifications[index].typeLabel,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _notifications = _notifications.map((n) => NotificationModel(
      id: n.id,
      title: n.title,
      description: n.description,
      timestamp: n.timestamp,
      type: n.type,
      isRead: true,
      typeLabel: n.typeLabel,
    )).toList();
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repository.clearAllNotifications();
    _notifications.clear();
    notifyListeners();
  }
}
