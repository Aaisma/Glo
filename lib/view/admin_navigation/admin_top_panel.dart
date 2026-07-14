import 'package:flutter/material.dart';

class AdminTopPanel extends StatelessWidget implements PreferredSizeWidget {
  const AdminTopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFEAF3FD),
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF4F8FE0)),
      title: const Text(
        "✨ Glow begins with care ✨",
        style: TextStyle(color: Color(0xFF4F8FE0), fontStyle: FontStyle.italic, fontSize: 16),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Chip(
            avatar: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 16, color: Color(0xFF4F8FE0))),
            label: const Text("Admin"),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
