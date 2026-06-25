import 'package:flutter/material.dart';
import 'package:Gloclone/models/notification_model.dart';

class NotificationBadge extends StatelessWidget {
  final NotificationType type;
  final String label;

  const NotificationBadge({
    Key? key,
    required this.type,
    required this.label,
  }) : super(key: key);

  Color _getBadgeColor() {
    switch (type) {
      case NotificationType.ovulation:
      case NotificationType.period:
      case NotificationType.periodLog:
        return const Color(0xFFFFEBEE);
      case NotificationType.medication:
      case NotificationType.dermaVisit:
      case NotificationType.acne:
        return const Color(0xFFF3E5F5);
      case NotificationType.moodTracker:
      case NotificationType.journal:
      case NotificationType.water:
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case NotificationType.ovulation:
      case NotificationType.period:
      case NotificationType.periodLog:
        return const Color(0xFFE91E63);
      case NotificationType.medication:
      case NotificationType.dermaVisit:
      case NotificationType.acne:
        return const Color(0xFF9C27B0);
      case NotificationType.moodTracker:
      case NotificationType.journal:
      case NotificationType.water:
      default:
        return const Color(0xFFFB8C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );
  }
}