import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../glo_notification/notification_screen.dart';
import '../../viewmodel/profile_viewmodel.dart';

class TopNavigation extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final bool showGreeting;

  const TopNavigation({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.showGreeting = true,
  });

  @override
  Widget build(BuildContext context) {
    String greetingText = "⟡˙⋆Welcome to Glo⋆˙⟡";
    if (isLoggedIn && showGreeting) {
      final profileVM = context.watch<ProfileViewModel>();
      greetingText = "Good Morning, ${profileVM.username}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: showGreeting ? Text(
              greetingText,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF3E63),
              ),
            ) : const SizedBox.shrink(),
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
