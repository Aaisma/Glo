import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/wellness_viewmodel.dart';

import 'view/glo_mood/wellness_dashboard_screen.dart';
import 'view/glo_mood/mood_log_screen.dart';
import 'view/glo_mood/mood_garden_screen.dart';
import 'view/glo_mood/mood_calendar_screen.dart';
import 'view/glo_mood/mood_summary_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => WellnessViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo',
        theme: ThemeData(useMaterial3: true),
        initialRoute: '/dashboard',
        routes: {
          '/dashboard': (context) => const WellnessDashboardScreen(),
          '/mood_log': (context) => const MoodLogScreen(),
          '/mood_garden': (context) => const MoodGardenScreen(),
          '/mood_calendar': (context) => const MoodCalendarScreen(),
          '/mood_summary': (context) => const MoodSummaryScreen(),
        },
      ),
    );
  }
}