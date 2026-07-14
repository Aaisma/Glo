import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/notification_model.dart';
import 'notification_repo.dart';

class NotificationRepoImpl implements NotificationRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final snapshot = await _db
          .collection("notifications")
          .orderBy("createdAt", descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("❌ Error fetching notifications: $e");
      return [];
    }
  }

  @override
  Future<void> addNotification({
    required String title,
    required String desc,
    required String badge,
    required String icon,
  }) async {
    try {
      await _db.collection("notifications").add({
        "title": title,
        "desc": desc,
        "badge": badge,
        "icon": icon,
        "unread": true,
        "day": "Today",
        "time": "Just now",
        "createdAt": FieldValue.serverTimestamp(),
      });
      debugPrint("✅ Notification added: $title");
    } catch (e) {
      debugPrint("❌ Error adding notification: $e");
    }
  }

  @override
  Future<void> updateNotificationReadStatus(String id, bool isRead) async {
    try {
      await _db.collection("notifications").doc(id).update({
        "unread": !isRead,
      });
      debugPrint("✅ Notification read status updated: $id");
    } catch (e) {
      debugPrint("❌ Error updating notification read status: $e");
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final snapshot = await _db
          .collection("notifications")
          .where("unread", isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {"unread": false});
      }
      await batch.commit();
      debugPrint("✅ All notifications marked as read");
    } catch (e) {
      debugPrint("❌ Error marking all notifications as read: $e");
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      final snapshot = await _db.collection("notifications").get();
      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint("✅ All notifications cleared");
    } catch (e) {
      debugPrint("❌ Error clearing all notifications: $e");
    }
  }
}
