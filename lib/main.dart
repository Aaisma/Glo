import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/firebase_options.dart';

// Repositories
import 'package:glo/repo/notification_repository_impl.dart';
import 'package:glo/repo/mood_repository.dart';
import 'package:glo/repo/mood_repository_impl.dart';

// Services
import 'package:glo/services/firebase_notification_service.dart';
import 'package:glo/services/local_notification_service.dart';

// ViewModels / Providers
import 'package:glo/providers/notification_provider.dart';
import 'package:glo/viewmodel/wellness_viewmodel.dart';

// Screens
import 'package:glo/view/notification_screen.dart';
import 'package:glo/view/wellness_dashboard_screen.dart';
import 'package:glo/view/mood_log_screen.dart';
import 'package:glo/view/mood_garden_screen.dart';
import 'package:glo/view/mood_calendar_screen.dart';
import 'package:glo/view/mood_summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Notification Providers
        Provider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(
            firebaseService: FirebaseNotificationService(),
            localService: LocalNotificationService(),
          ),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (context) => NotificationProvider(
            context.read<NotificationRepository>(),
          ),
        ),
        // Wellness MVVM Provider
        ChangeNotifierProvider<WellnessViewModel>(
          create: (_) => WellnessViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Glo Wellness',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          fontFamily: 'Roboto',
        ),
        home: const WellnessDashboardScreen(),
        routes: {
          '/notifications': (context) => const NotificationScreen(),
          '/wellness': (context) => const WellnessDashboardScreen(),
          '/mood_log': (context) => const MoodLogScreen(),
          '/mood_garden': (context) => const MoodGardenScreen(),
          '/mood_calendar': (context) => const MoodCalendarScreen(),
          '/mood_summary': (context) => const MoodSummaryScreen(),
        },
      ),
    );
  }
}
