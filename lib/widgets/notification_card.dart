import 'package:flutter/material.dart';
import 'package:Glo/models/notification_model.dart';
import 'package:Glo/widgets/notification_badge.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE96581).withValues(alpha: 0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE96581),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 14),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      NotificationBadge(label: item.tag),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 12,
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
                  item.time,
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.isUnread)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE96581),
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Icon(Icons.chevron_right, color: Color(0xFFFFCCD3), size: 18),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}