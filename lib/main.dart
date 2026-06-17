import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


import 'viewmodel/wellness_viewmodel.dart';

import 'view/mood_calendar_screen.dart';
import 'view/mood_garden_screen.dart';
import 'view/mood_log_screen.dart';
import 'view/mood_summary_screen.dart';
import 'view/wellness_dashboard_screen.dart';

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
        ChangeNotifierProvider<WellnessViewModel>(
          create: (_) => WellnessViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'GloClone Wellness App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFFFF3E63),
          scaffoldBackgroundColor: const Color(0xFFFAF7F2),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AppOnboardingWrapper(),
          '/mood_log': (context) => const MoodLogScreen(),
          '/mood_garden': (context) => const MoodGardenScreen(),
          '/mood_summary': (context) => const MoodSummaryScreen(),
          '/mood_calendar': (context) => const MoodCalendarScreen(),
        },
      ),
    );
  }
}

class AppOnboardingWrapper extends StatefulWidget {
  const AppOnboardingWrapper({super.key});

  @override
  State<AppOnboardingWrapper> createState() => _AppOnboardingWrapperState();
}

class _AppOnboardingWrapperState extends State<AppOnboardingWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      const String currentMockUserId = "CURRENT_USER_ID";

      Provider.of<WellnessViewModel>(context, listen: false)
          .initUserSync(currentMockUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const WellnessDashboardScreen();
  }
}