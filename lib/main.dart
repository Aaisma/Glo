import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD

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
import 'package:glo/view/authentication/glo_otp.dart';

// Admin
import 'package:glo/view/health_overview_screen.dart';

Future<void> main() async {
=======
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'view/glo_splash_screen.dart';
import 'view/authentication/auth_wrapper.dart';
import 'view/authentication/authentication_page.dart';
import 'view/authentication/login_screen.dart';
import 'view/authentication/register_screen.dart';
import 'view/survey_page.dart';
import 'view/navigation_icon/glo_profile.dart';
import 'view/dashboard_page.dart';
import 'view/admin/admin_dashboard_page.dart';

// Repos
import 'repo/user_repo_impl.dart';
import 'repo/auth_repo_impl.dart';
import 'repo/period_repo_impl.dart';
import 'repo/ovulation_repo_impl.dart';
import 'repo/insights_repo_impl.dart';
import 'repo/community_repo_impl.dart';
import 'repo/insights_moderation_repo_impl.dart';
import 'repo/community_moderation_repo_impl.dart';
import 'repo/acne_repo_impl.dart';

// ViewModels
import 'viewmodel/user_view_model.dart';
import 'viewmodel/auth_view_model.dart';
import 'viewmodel/period_view_model.dart';
import 'viewmodel/ovulation_view_model.dart';
import 'viewmodel/insight_view_model.dart';
import 'viewmodel/community_view_model.dart';
import 'viewmodel/moderation_view_model.dart';
import 'viewmodel/tracker_navigation_view_model.dart';
import 'viewmodel/acne_tracker_viewmodel.dart';

void main() async {
>>>>>>> 833f232 (Updated top and bottom navigation to modify calender placement.)
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

<<<<<<< HEAD
  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({super.key});

  static const String testUserId = "test-user-001";
  static const String testPhone = "+9779800000000";

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
    return GloOtpScreen(phone: phone);
  }
=======
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('insights_box');
  await Hive.openBox('community_box');
  await Hive.openBox('insights_moderation_box');
  await Hive.openBox('community_moderation_box');
  await Hive.openBox('drafts_box');
  await Hive.openBox('favorites_box');
  await Hive.openBox('hidden_content_box');
  await Hive.openBox('onboarding_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
>>>>>>> 833f232 (Updated top and bottom navigation to modify calender placement.)

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
<<<<<<< HEAD
        ChangeNotifierProvider<MedicationViewModel>(
          create: (_) => MedicationViewModel(),
        ),
        ChangeNotifierProvider<VisitViewModel>(
          create: (_) => VisitViewModel(),
        ),
        ChangeNotifierProvider<HealthViewModel>(
          create: (_) => HealthViewModel(),
        ),
        ChangeNotifierProvider<OtpViewModel>(
          create: (_) => OtpViewModel(),
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

        // Testing OTP directly.
        home: const GloOtpScreen(
          phone: testPhone,
        ),

        // To test Derma Visit instead, replace home above with:
        // home: const DermaVisitScreen(
        //   userId: testUserId,
        // ),

        routes: {
          '/home': (_) => const GloProfileScreen(),
          '/history': (_) => const HistoryScreen(),
          '/profile': (_) => const GloProfileScreen(),

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
=======
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Project',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/authWrapper': (context) => const AuthWrapper(),
          '/authentication': (context) => const AuthenticationPage(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/survey': (context) => const SurveyPage(),
          '/gloProfile': (context) => const GloProfileScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/adminDashboard': (context) => const AdminDashboardPage(),
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      if (authVM.user != null) {
        // await authVM.checkUserProfile(context, authVM.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    if (authVM.user != null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const AuthenticationPage();
  }
}
>>>>>>> 833f232 (Updated top and bottom navigation to modify calender placement.)
