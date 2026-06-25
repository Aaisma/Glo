import 'package:flutter/material.dart';
import 'view/admin_dashboard_screen.dart';

void main() {
  runApp(const AdminTestApp());
}

class AdminTestApp extends StatelessWidget {
  const AdminTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboardScreen(),
    );
  }
}