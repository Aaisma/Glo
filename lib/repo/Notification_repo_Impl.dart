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
  Future<void> updateReadStatus(String id, bool isRead) async {
    try {
      await _db.collection("notifications").doc(id).update({
        "unread": false, // ✅ explicitly mark as read
      });
    } catch (e) {
      debugPrint("❌ Error updating read status: $e");
    }
  }

  @override
  Future<NotificationModel> saveNotification(NotificationModel notification) async {
    try {
      final docRef = await _db.collection("notifications").add({
        "title": notification.title,
        "desc": notification.desc,
        "time": notification.time,
        "day": notification.day,
        "badge": notification.badge,
        "icon": notification.icon,
        "unread": notification.unread,
        "createdAt": Timestamp.fromDate(notification.createdAt),
      });

      debugPrint("✅ Notification saved successfully with ID: ${docRef.id}");
      return notification.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint("❌ Error saving notification: $e");
      return notification;
    }
  }

  @override
  Future<void> addNotification({required String title, required String desc, required String badge, required String icon}) {
    // TODO: implement addNotification
    throw UnimplementedError();
  }

  @override
  Future<void> updateNotificationReadStatus(String id, bool isRead) {
    // TODO: implement updateNotificationReadStatus
    throw UnimplementedError();
  }
}
