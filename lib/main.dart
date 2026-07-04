import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// ViewModels
import 'package:glo/viewmodel/health_viewmodel.dart';
import 'package:glo/viewmodel/history_viewmodel.dart';
import 'package:glo/viewmodel/image_viewmodel.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';
import 'package:glo/viewmodel/otp_viewmodel.dart';
import 'package:glo/viewmodel/profile_viewmodel.dart';
import 'package:glo/viewmodel/visit_viewmodel.dart';

// Repos
import 'package:glo/repo/history_repo_impl.dart';
import 'package:glo/repo/image_repo_impl.dart';

// Services
import 'package:glo/services/history_service.dart';

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
import 'package:glo/view/glo_otp/glo_otp.dart';

// Admin
import 'package:glo/view/health_overview_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  static const String testUserId = "test-user-001";
  static const String testPhone = "+9779765599190";

  String _getUserIdFromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String && args.trim().isNotEmpty) {
      return args;
    }

    if (args is Map && args['userId'] is String) {
      final userId = args['userId'] as String;

      if (userId.trim().isNotEmpty) {
        return userId;
      }
    }

    return testUserId;
  }

  String _getPhoneFromRoute(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String && args.trim().isNotEmpty) {
      return args;
    }

    if (args is Map && args['phone'] is String) {
      final phone = args['phone'] as String;

      if (phone.trim().isNotEmpty) {
        return phone;
      }
    }

    return testPhone;
  }

  Widget _medicationScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return MedicationScreen(userId: userId);
  }

  Widget _addMedicationScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return AddMedicationScreen(userId: userId);
  }

  Widget _medicationHistoryScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return MedicationHistoryScreen(userId: userId);
  }

  Widget _dermaVisitScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return DermaVisitScreen(userId: userId);
  }

  Widget _visitLogScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return LogVisitScreen(userId: userId);
  }

  Widget _followUpReminderScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return FollowUpReminderScreen(userId: userId);
  }

  Widget _prescriptionScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return PrescriptionScreen(userId: userId);
  }

  Widget _skinTipsScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return SkinHealthTipsScreen(userId: userId);
  }

  Widget _treatmentTrackerScreen(BuildContext context) {
    final userId = _getUserIdFromRoute(context);
    return TreatmentTrackerScreen(userId: userId);
  }

  Widget _otpScreen(BuildContext context) {
    final phone = _getPhoneFromRoute(context);

    return GloOtpScreen(
      phone: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OtpViewModel>(
          create: (_) => OtpViewModel(),
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
        title: "Glo App",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9BD8FA),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4FBFF),
        ),

        // Testing Profile directly
        home: const GloProfileScreen(),

        routes: {
          '/login': (_) => const GloOtpScreen(phone: testPhone),

          '/home': (_) => const GloProfileScreen(),
          '/profile': (_) => const GloProfileScreen(),
          '/history': (_) => const HistoryScreen(),

          '/adminOverview': (_) => const HealthOverviewScreen(),

          '/medications': (context) => _medicationScreen(context),
          '/addMedication': (context) => _addMedicationScreen(context),
          '/medicationHistory': (context) => _medicationHistoryScreen(context),

          '/insights': (context) => _dermaVisitScreen(context),
          '/dermaVisit': (context) => _dermaVisitScreen(context),
          '/visitLog': (context) => _visitLogScreen(context),
          '/followUpReminder': (context) => _followUpReminderScreen(context),
          '/prescription': (context) => _prescriptionScreen(context),
          '/skinTips': (context) => _skinTipsScreen(context),
          '/treatmentTracker': (context) => _treatmentTrackerScreen(context),

          '/about': (_) => const GloAboutUsScreen(),

          '/otp': (context) => _otpScreen(context),
        },
      ),
    );
  }
}