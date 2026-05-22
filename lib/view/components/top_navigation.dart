import 'package:flutter/material.dart';
import 'package:glo/view/navigation_icon/calendar_screen.dart';
import 'package:glo/view/navigation_icon/notification_page.dart';

class TopNavigation extends StatelessWidget {
  const TopNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Good Morning Victoria ❤️",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3E63),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Color(0xFF332B2C)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CalendarScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Color(0xFF332B2C)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()),
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
