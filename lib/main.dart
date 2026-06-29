import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gloclone/repo/notification_repo.dart';
import 'package:gloclone/viewmodel/notification_view_model.dart';
import 'package:gloclone/view/notification_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupNotificationClickHandling();
    _testFirestoreConnection(); // 🔥 Firestore test on startup
  }

  void _setupNotificationClickHandling() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToNotificationScreen();
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToNotificationScreen();
    });
  }

  void _navigateToNotificationScreen() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  }

  /// 🔥 Firestore test: writes a document to confirm connection
  Future<void> _testFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('connection_test')
          .add({'status': 'connected', 'time': DateTime.now()});
      print("✅ Firestore write successful!");
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      print("❌ Firestore error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationRepo>(
          create: (_) => NotificationRepo(),
        ),
        ChangeNotifierProxyProvider<NotificationRepo, NotificationViewModel>(
          create: (context) => NotificationViewModel(
              Provider.of<NotificationRepo>(context, listen: false)),
          update: (context, repository, previousViewModel) =>
          previousViewModel ?? NotificationViewModel(repository),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Firebase Error: $_errorMessage",
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return const NotificationScreen();
  }
}
