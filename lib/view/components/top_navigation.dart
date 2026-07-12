import 'package:flutter/material.dart';
import '../glo_notification/notification_screen.dart';

class TopNavigation extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;

  const TopNavigation({
    super.key,
    this.isLoggedIn = false,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              isLoggedIn ? "Good Morning ${userName ?? 'User'} ❤︎"
                  : "⟡˙⋆Welcome to Glo⋆˙⟡",
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF3E63),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF332B2C), size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
