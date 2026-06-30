import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
=======

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'repo/user_repo_impl.dart';
import 'repo/acne_repo_impl.dart';

import 'viewmodel/user_view_model.dart';
import 'viewmodel/acne_tracker_viewmodel.dart';

import 'view/acne_tracker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AcneTestApp());
=======
import 'package:hive_flutter/hive_flutter.dart';
>>>>>>> f308e7b9b107ea0fea702914e60289a0f9179c95
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

<<<<<<< HEAD
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationClickHandling();
      _testFirestoreConnection();
    });
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

  Future<void> _testFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance.collection('connection_test').add({
        'status': 'connected',
        'time': DateTime.now(),
      });
      debugPrint("✅ Firestore write successful!");
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
      debugPrint("❌ Firestore error: $e");
    }
  }
=======
class AcneTestApp extends StatelessWidget {
  const AcneTestApp({super.key});
>>>>>>> f308e7b9b107ea0fea702914e60289a0f9179c95

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
<<<<<<< HEAD
        ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => NotificationViewModel(),
        ),
=======
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),

        ChangeNotifierProvider(create: (_) => AcneTrackerViewModel(AcneRepoImpl())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Acne Tracker Test',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: const AcneTrackerPage(),
      ),
    );
  }
}

        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo: AuthRepoImpl(), userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => PeriodViewModel(PeriodRepoImpl())),
        ChangeNotifierProvider(create: (_) => OvulationViewModel(OvulationRepoImpl())),
        ChangeNotifierProvider(create: (_) => TrackerNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => AcneTrackerViewModel(AcneRepoImpl())),

        // Insights Module ViewModels
        ChangeNotifierProvider(create: (_) => InsightsFeedViewModel(InsightsRepoImpl())),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel(InsightsRepoImpl(), CommunityRepoImpl())),
        ChangeNotifierProvider(create: (_) => CreateInsightViewModel(InsightsRepoImpl())),
        ChangeNotifierProvider(create: (_) => InsightsLibraryViewModel(InsightsRepoImpl())),
        ChangeNotifierProvider(create: (_) => ArticleDetailViewModel(InsightsRepoImpl(), InsightsModerationRepoImpl())),

        // Community Module ViewModels
        ChangeNotifierProvider(create: (_) => CommunityFeedViewModel(CommunityRepoImpl())),
        ChangeNotifierProvider(create: (_) => DiscussionDetailViewModel(CommunityRepoImpl(), CommunityModerationRepoImpl())),
        ChangeNotifierProvider(create: (_) => CreateDiscussionViewModel(CommunityRepoImpl())),
        ChangeNotifierProvider(create: (_) => CreatePollViewModel(CommunityRepoImpl())),
        ChangeNotifierProvider(create: (_) => CommunityLibraryViewModel(CommunityRepoImpl())),

        // Separated Moderation ViewModels
        ChangeNotifierProvider(create: (_) => InsightsModerationQueueViewModel(InsightsModerationRepoImpl())),
        ChangeNotifierProvider(create: (_) => InsightsModerationDetailViewModel(InsightsModerationRepoImpl())),
        ChangeNotifierProvider(create: (_) => CommunityModerationQueueViewModel(CommunityModerationRepoImpl())),
        ChangeNotifierProvider(create: (_) => CommunityModerationDetailViewModel(CommunityModerationRepoImpl())),
>>>>>>> f308e7b9b107ea0fea702914e60289a0f9179c95
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Firebase Error:\n$_errorMessage",
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const NotificationScreen();
  }
<<<<<<< HEAD
}
=======
}

>>>>>>> f308e7b9b107ea0fea702914e60289a0f9179c95
