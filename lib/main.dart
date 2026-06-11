import 'package:flutter/material.dart';
import 'view/about_us_screen.dart';
import 'view/add_medication_screen.dart';
import 'view/dermavisit.dart';
import 'view/follow_up_reminder.dart';
import 'view/glo_otp.dart';
import 'view/glo_profile.dart';
import 'view/glo_splash_screen.dart';
import 'view/medication_history_screen.dart';
import 'view/medications_screen.dart';
import 'view/prescription.dart';
import 'view/skin_tips.dart';
import 'view/treatment_tracker.dart';
import 'view/visit_log.dart';

void main() {
  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto',
      ),
      // Start with splash screen
      home: const GloOtpScreen (),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/profile': (context) => const GloProfileScreen(),
        '/otp': (context) => const GloOtpScreen(),
        '/medications': (context) => const MedicationScreen(),
        '/addMedication': (context) => const AddMedicationScreen(),
        '/medicationHistory': (context) => const MedicationHistoryScreen(),
        '/dermaVisit': (context) => const DermaVisitScreen(),
        '/followUpReminder': (context) => const ReminderScreen(),
        '/prescription': (context) => const PrescriptionScreen(),
        '/skinTips': (context) => const SkinHealthTipsScreen(),
        '/treatmentTracker': (context) => const TreatmentTrackerScreen(),
        '/visitLog': (context) => const LogVisitScreen(),
        '/aboutUs': (context) => const AboutUsScreen(),
      },
    );
  }
}
