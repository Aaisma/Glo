import 'package:flutter/material.dart';
import 'package:glo/view/navigation_icon/notification_page.dart';

class TopNavigation extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? title;

  const TopNavigation({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = title ??
        (isLoggedIn
            ? "Good Morning ${userName ?? 'User'} ❤︎"
            : " ⟡˙⋆Welcome to Glo⋆˙⟡");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          if (isLoggedIn || title != null) const SizedBox(width: 48),
          Expanded(
            child: Text(
              headerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF3E63),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Color(0xFF332B2C),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}