import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glo/models/notification_model.dart';
import 'package:glo/widgets/notification_badge.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  Widget _buildIcon() {
    Color bg;
    Widget icon;

    switch (notification.type) {
      case NotificationType.ovulation:
        bg = const Color(0xFFFFF0F2);
        icon = const Text('🌸', style: TextStyle(fontSize: 22));
        break;
      case NotificationType.medication:
        bg = const Color(0xFFFFF5EB);
        icon = const Text('💊', style: TextStyle(fontSize: 22));
        break;
      case NotificationType.moodTracker:
        bg = const Color(0xFFFFFDE7);
        icon = const Text('😊', style: TextStyle(fontSize: 22));
        break;
      case NotificationType.dermaVisit:
        bg = const Color(0xFFE0F7FA);
        icon = const Icon(Icons.medical_services_outlined, color: Colors.cyan, size: 24);
        break;
      case NotificationType.period:
        bg = const Color(0xFFFFEBEE);
        icon = const Text('🩸', style: TextStyle(fontSize: 22));
        break;
      case NotificationType.periodLog:
        bg = const Color(0xFFFFE0F4);
        icon = const Icon(Icons.calendar_today_outlined, color: Colors.pinkAccent, size: 22);
        break;
      case NotificationType.journal:
        bg = const Color(0xFFF3E5F5);
        icon = const Icon(Icons.book_outlined, color: Colors.purple, size: 22);
        break;
      case NotificationType.water:
        bg = const Color(0xFFE3F2FD);
        icon = const Text('💧', style: TextStyle(fontSize: 22));
        break;
      case NotificationType.acne:
        bg = const Color(0xFFE8F5E9);
        icon = const Text('✨', style: TextStyle(fontSize: 22));
        break;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      alignment: Alignment.center,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('h:mm a').format(notification.timestamp);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 22, right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.isRead ? Colors.transparent : const Color(0xFFE91E63),
              ),
            ),
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      NotificationBadge(type: notification.type, label: notification.badgeText),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeString,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Icon(Icons.chevron_right, size: 16, color: Colors.grey[400]),
              ],
            )
          ],
        ),
      ),
    );
  }
}