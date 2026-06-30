import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// ViewModels
import 'package:glo/viewmodel/auth_viewmodel.dart';
import 'package:glo/viewmodel/health_viewmodel.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';
import 'package:glo/viewmodel/visit_viewmodel.dart';

// Screens
import 'package:glo/view/glo_profile/glo_profile.dart';
import 'package:glo/view/glo_history/history_screen.dart';

import 'package:glo/view/glo_medication/medication_screen.dart';
import 'package:glo/view/glo_medication/add_medication_screen.dart';
import 'package:glo/view/glo_medication/medication_history_screen.dart';

import 'package:glo/view/glo_derma_visit/derma_visit.dart';
import 'package:glo/view/glo_derma_visit/visit_log.dart';
import 'package:glo/view/glo_derma_visit/follow_up_reminder.dart';
import 'package:glo/view/glo_derma_visit/prescription.dart';
import 'package:glo/view/glo_derma_visit/skin_tips.dart';
import 'package:glo/view/glo_derma_visit/treatment_tracker.dart';

import 'package:glo/view/glo_profile/glo_about_us_screen.dart';
import 'package:glo/view/authentication/glo_otp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  static const String userId = "testUser123";

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<MedicationViewModel>(
          create: (_) => MedicationViewModel(),
        ),
        ChangeNotifierProvider<VisitViewModel>(
          create: (_) => VisitViewModel(),
        ),
        ChangeNotifierProvider<HealthViewModel>(
          create: (_) => HealthViewModel(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Glo App",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF7F8),
        ),

        // Initial Screen
        home: const HistoryScreen(),

        routes: {
          // Bottom Navigation Routes
          // Replace these with your actual Home/Insights pages later
          '/home': (_) => const GloProfileScreen(),
          '/insights': (_) => const DermaVisitScreen(),
          '/history': (_) => const HistoryScreen(),
          '/profile': (_) => const GloProfileScreen(),

          // Medication
          '/medications': (_) => const MedicationScreen(
            userId: userId,
          ),
          '/addMedication': (_) => const AddMedicationScreen(
            userId: userId,
          ),
          '/medicationHistory': (_) => const MedicationHistoryScreen(
            userId: userId,
          ),

          // Derma Visit
          '/dermaVisit': (_) => const DermaVisitScreen(),
          '/visitLog': (_) => const LogVisitScreen(),
          '/followUpReminder': (_) => const FollowUpReminderScreen(),
          '/prescription': (_) => const PrescriptionScreen(),
          '/skinTips': (_) => const SkinHealthTipsScreen(),
          '/treatmentTracker': (_) => const TreatmentTrackerScreen(),

          // Profile
          '/about': (_) => const GloAboutUsScreen(),

          // Authentication
          '/otp': (_) => const GloOtpScreen(),
        },
      ),
    );
  }
}