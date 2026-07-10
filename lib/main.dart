import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ViewModels
import 'package:glo/viewmodel/health_viewmodel.dart';
import 'package:glo/viewmodel/history_viewmodel.dart';
import 'package:glo/viewmodel/image_viewmodel.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';
import 'package:glo/viewmodel/profile_viewmodel.dart';
import 'package:glo/viewmodel/visit_viewmodel.dart';

// Repositories
import 'package:glo/repo/history_repo_impl.dart';
import 'package:glo/repo/image_repo_impl.dart';

// Services
import 'package:glo/services/firestore_history_service.dart';
import 'package:glo/services/history_service.dart';

// Profile
import 'package:glo/view/glo_profile/glo_profile.dart';
import 'package:glo/view/glo_profile/glo_about_us_screen.dart';

// History
import 'package:glo/view/glo_history/history_screen.dart';

// Medication
import 'package:glo/view/glo_medication/add_medication_screen.dart';
import 'package:glo/view/glo_medication/medication_history_screen.dart';
import 'package:glo/view/glo_medication/medication_screen.dart';

// Doctor Visit
import 'package:glo/view/glo_derma_visit/derma_visit.dart';
import 'package:glo/view/glo_derma_visit/follow_up_reminder.dart';
import 'package:glo/view/glo_derma_visit/prescription.dart';
import 'package:glo/view/glo_derma_visit/skin_tips.dart';
import 'package:glo/view/glo_derma_visit/treatment_tracker.dart';
import 'package:glo/view/glo_derma_visit/visit_log.dart';

// Admin
import 'package:glo/view/health_overview_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  if (!Hive.isBoxOpen('onboarding_box')) {
    await Hive.openBox('onboarding_box');
  }

  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  static const String testUserId = 'test-user-001';

  String _currentUserId() {
    final uid = FirebaseAuth.instance.currentUser?.uid.trim();

    if (uid != null && uid.isNotEmpty) {
      return uid;
    }

    return testUserId;
  }

  String _getUserIdFromRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }

    if (arguments is Map) {
      final userId = arguments['userId'];

      if (userId is String && userId.trim().isNotEmpty) {
        return userId.trim();
      }
    }

    return _currentUserId();
  }

  Widget _medicationScreen(BuildContext context) {
    return MedicationScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _addMedicationScreen(BuildContext context) {
    return AddMedicationScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _medicationHistoryScreen(BuildContext context) {
    return MedicationHistoryScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _dermaVisitScreen(BuildContext context) {
    return DermaVisitScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _visitLogScreen(BuildContext context) {
    return LogVisitScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _followUpReminderScreen(BuildContext context) {
    return FollowUpReminderScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _prescriptionScreen(BuildContext context) {
    return PrescriptionScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _skinTipsScreen(BuildContext context) {
    return SkinHealthTipsScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  Widget _treatmentTrackerScreen(BuildContext context) {
    return TreatmentTrackerScreen(
      userId: _getUserIdFromRoute(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreHistoryService>(
          create: (_) => FirestoreHistoryService(),
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
        ChangeNotifierProvider<ImageViewModel>(
          create: (_) => ImageViewModel(
            ImageRepoImpl(),
          ),
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
        ),
        ChangeNotifierProvider<HistoryViewModel>(
          create: (_) => HistoryViewModel(
            HistoryRepoImpl(
              HistoryService(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9BD8FA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4FBFF),
        ),

        home: const HistoryScreen(),

        routes: {
          // Temporary until OTP/login is connected again.
          '/login': (_) => const GloProfileScreen(),

          '/home': (_) => const GloProfileScreen(),
          '/profile': (_) => const GloProfileScreen(),
          '/history': (_) => const HistoryScreen(),
          '/calendar': (_) => const CalendarPlaceholderScreen(),

          '/adminOverview': (_) => const HealthOverviewScreen(),

          '/medications': _medicationScreen,
          '/addMedication': _addMedicationScreen,
          '/medicationHistory': _medicationHistoryScreen,

          '/insights': _dermaVisitScreen,
          '/dermaVisit': _dermaVisitScreen,
          '/visitLog': _visitLogScreen,
          '/followUpReminder': _followUpReminderScreen,
          '/prescription': _prescriptionScreen,
          '/skinTips': _skinTipsScreen,
          '/treatmentTracker': _treatmentTrackerScreen,

          '/about': (_) => const GloAboutUsScreen(),
        },
      ),
    );
  }
}

class CalendarPlaceholderScreen extends StatelessWidget {
  const CalendarPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: const Center(
        child: Text(
          'Calendar screen is not connected yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}