import 'package:flutter/material.dart';
import 'package:glo/model/notification_model.dart';
import 'package:glo/repo/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _repo;

  NotificationViewModel({required NotificationRepo notificationRepo}) : _repo = notificationRepo;

  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  String _selectedTab = "All";
  bool _isLoading = false;

  List<NotificationModel> get filteredNotifications => _filteredNotifications;
  String get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<NotificationModel> remoteNotes = await _repo.fetchNotifications();

      if (remoteNotes.isEmpty) {
        await seedWelcomeNotifications();
        remoteNotes = await _repo.fetchNotifications();
      }

      _allNotifications = remoteNotes;
      _filterNotifications();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> seedWelcomeNotifications() async {
    final welcomeItems = [
      {
        "title": "Ovulation in 2 days",
        "desc": "Your fertile window is starting soon. Take care! 🌸",
        "badge": "Ovulation",
        "icon": "🌸",
      },
      {
        "title": "Time to take Iron Supplement",
        "desc": "Consistency is the key to better health. 💊",
        "badge": "Medication",
        "icon": "💊",
      },
      {
        "title": "Don't forget to log your mood",
        "desc": "How are you feeling today? Your Mood Garden misses you! 🌼",
        "badge": "Mood Tracker",
        "icon": "😊",
      },
      {
        "title": "Derma Visit Tomorrow",
        "desc": "You have a dermatology appointment tomorrow at 10:00 AM.",
        "badge": "Derma Visit",
        "icon": "👩‍⚕️",
      },
      {
        "title": "Period expected in 3 days",
        "desc": "Your period is expected on April 06, 2026.",
        "badge": "Period",
        "icon": "🩸",
      }
    ];

    for (var note in welcomeItems) {
      await _repo.addNotification(
        title: note["title"]!,
        desc: note["desc"]!,
        badge: note["badge"]!,
        icon: note["icon"]!,
      );
    }
  }

  Future<void> createNotification({
    required String title,
    required String desc,
    required String badge,
    required String icon,
  }) async {
    try {
      await _repo.addNotification(
        title: title,
        desc: desc,
        badge: badge,
        icon: icon,
      );

      _allNotifications = await _repo.fetchNotifications();
      _filterNotifications();
    } catch (e) {
      debugPrint("Error creating notification: $e");
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _allNotifications.indexWhere((note) => note.id == id);
    if (index != -1 && _allNotifications[index].unread) {
      try {
        await _repo.updateNotificationReadStatus(id, true);

        _allNotifications[index] = NotificationModel(
          id: _allNotifications[index].id,
          title: _allNotifications[index].title,
          desc: _allNotifications[index].desc,
          badge: _allNotifications[index].badge,
          icon: _allNotifications[index].icon,
          unread: false,
          day: _allNotifications[index].day,
          time: _allNotifications[index].time,
          createdAt: _allNotifications[index].createdAt,
        );
        _filterNotifications();
      } catch (e) {
        debugPrint("Error marking notification as read: $e");
      }
    }
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    _filterNotifications();
  }

  void _filterNotifications() {
    if (_selectedTab == "All") {
      _filteredNotifications = List.from(_allNotifications);
    } else if (_selectedTab == "Unread") {
      _filteredNotifications = _allNotifications.where((note) => note.unread).toList();
    } else {
      _filteredNotifications = _allNotifications.where((note) => !note.unread).toList();
    }
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      _allNotifications = await _repo.fetchNotifications();
      _filterNotifications();
    } catch (e) {
      debugPrint("Error marking all as read: $e");
    }
  }

  Future<void> clearAll() async {
    try {
      await _repo.clearAll();
      _allNotifications = [];
      _filterNotifications();
    } catch (e) {
      debugPrint("Error clearing all notifications: $e");
    }
  }
}