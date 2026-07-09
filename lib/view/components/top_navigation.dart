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
        children: [
          // Spacer to help center the text if there are icons on the right
          if (isLoggedIn) const SizedBox(width: 48), 
          Expanded(
            child: Text(
              isLoggedIn ? "Good Morning ${userName ?? 'User'} ❤︎"
                  : "⟡˙⋆Welcome to Glo⋆˙⟡",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF3E63),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF332B2C)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
