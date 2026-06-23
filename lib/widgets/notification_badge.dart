import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final String label;

  const NotificationBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFE96581),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}