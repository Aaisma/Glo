import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/medication_viewmodel.dart';
import 'viewmodel/visit_viewmodel.dart';
import 'viewmodel/health_viewmodel.dart';

// Views
import 'view/glo_profile.dart';
import 'view/medication_screen.dart';
import 'view/add_medication_screen.dart';
import 'view/medication_history_screen.dart';
import 'view/dermavisit.dart';
import 'view/visit_log.dart';
import 'view/follow_up_reminder.dart';
import 'view/prescription.dart';
import 'view/skin_tips.dart';
import 'view/treatment_tracker.dart';
import 'view/about_us_screen.dart';
import 'view/glo_otp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String userId = "testUser123";

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => MedicationViewModel()),
        ChangeNotifierProvider(create: (_) => VisitViewModel()),
        ChangeNotifierProvider(create: (_) => HealthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo App',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: const Color(0xFFFFF7F8),
        ),
        home: MedicationScreen(userId: userId),
        routes: {
          '/profile': (context) => const GloProfileScreen(),
          '/medications': (context) => MedicationScreen(userId: userId),
          '/addMedication': (context) => const AddMedicationScreen(),
          '/medicationHistory': (context) =>
              MedicationHistoryScreen(userId: userId),
          '/dermaVisit': (context) => const DermaVisitScreen(),
          '/visitLog': (context) => const LogVisitScreen(),
          '/followUpReminder': (context) => const ReminderScreen(),
          '/prescription': (context) => const PrescriptionScreen(),
          '/skinTips': (context) => const SkinHealthTipsScreen(),
          '/treatmentTracker': (context) => const TreatmentTrackerScreen(),
          '/about': (context) => const AboutUsScreen(),
          '/otp': (context) => const GloOtpScreen(),
        },
      ),
    );
  }
}
