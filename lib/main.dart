import 'package:flutter/material.dart';
import 'package:gloclone/provider/notification_provider.dart';
import 'package:gloclone/view/notification_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationProvider notificationProvider = NotificationProvider();

    return MaterialApp(
      title: 'Glo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF5F5),
        useMaterial3: true,
        fontFamily: 'Sans-Serif',
      ),
      home: NotificationsScreen(),
    );
  }
}
