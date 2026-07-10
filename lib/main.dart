import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

// Views
import 'view/glo_splash/glo_splash_screen.dart';
import 'view/authentication/auth_wrapper.dart';
import 'view/authentication/authentication_page.dart';
import 'view/authentication/login_screen.dart';
import 'view/authentication/register_screen.dart';
import 'view/nutrition_tracker_screen.dart';
import 'view/survey_page.dart';
import 'view/navigation_icon/glo_profile.dart';
import 'view/dashboard_page.dart';
import 'package:glo/view/dashboard_card/admin/admin_dashboard_page.dart';
import 'view/admin_dashboard_screen.dart';

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
import 'repo/admin_monthly_tracking_repo.dart';
import 'repo/water_tracker_repo_impl.dart';
import 'repo/nutrition_repo_impl.dart';
// admin analytics removed — not part of this workspace owner

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
import 'viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'viewmodel/water_tracker_viewmodel.dart';
import 'viewmodel/nutrition_tracker_viewmodel.dart';
// admin analytics viewmodel removed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserViewModel(userRepo: UserRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AuthViewModel(authRepo: AuthRepoImpl(), userRepo: UserRepoImpl()),
        ),

        ChangeNotifierProxyProvider<UserViewModel, PeriodViewModel>(
          create: (_) => PeriodViewModel(PeriodRepoImpl()),
          update: (_, userVM, periodVM) =>
          periodVM!..updateUserId(userVM.userId),
        ),
        ChangeNotifierProxyProvider<UserViewModel, OvulationViewModel>(
          create: (_) => OvulationViewModel(OvulationRepoImpl()),
          update: (_, userVM, ovulationVM) =>
          ovulationVM!..updateUserId(userVM.userId),
        ),
        ChangeNotifierProxyProvider<UserViewModel, AcneTrackerViewModel>(
          create: (_) => AcneTrackerViewModel(AcneRepoImpl()),
          update: (_, userVM, acneVM) => acneVM!..updateUserId(userVM.userId),
        ),
        ChangeNotifierProxyProvider<UserViewModel, WaterTrackerViewModel>(
          create: (_) => WaterTrackerViewModel(WaterTrackerRepoImpl()),
          update: (_, userVM, waterVM) => waterVM!..updateUserId(userVM.userId),
        ),
        ChangeNotifierProxyProvider<UserViewModel, NutritionTrackerViewModel>(
          create: (_) => NutritionTrackerViewModel(NutritionRepoImpl()),
          update: (_, userVM, nutritionVM) =>
          nutritionVM!..updateUserId(userVM.userId),
        ),

        ChangeNotifierProvider(create: (_) => TrackerNavigationViewModel()),

        // Insights Module ViewModels
        ChangeNotifierProvider(
          create: (_) => InsightsFeedViewModel(InsightsRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              FavoritesViewModel(InsightsRepoImpl(), CommunityRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateInsightViewModel(InsightsRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => InsightsLibraryViewModel(InsightsRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => ArticleDetailViewModel(
            InsightsRepoImpl(),
            InsightsModerationRepoImpl(),
          ),
        ),

        // Community Module ViewModels
        ChangeNotifierProvider(
          create: (_) => CommunityFeedViewModel(CommunityRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => DiscussionDetailViewModel(
            CommunityRepoImpl(),
            CommunityModerationRepoImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateDiscussionViewModel(CommunityRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => CreatePollViewModel(CommunityRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityLibraryViewModel(CommunityRepoImpl()),
        ),

        // Separated Moderation ViewModels
        ChangeNotifierProvider(
          create: (_) =>
              InsightsModerationQueueViewModel(InsightsModerationRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              InsightsModerationDetailViewModel(InsightsModerationRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CommunityModerationQueueViewModel(CommunityModerationRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CommunityModerationDetailViewModel(CommunityModerationRepoImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AdminMonthlyTrackingViewModel(AdminMonthlyTrackingRepoImpl()),
        ),
        // Admin analytics provider removed (third-party feature)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Project',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const RegisterScreen(),
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
          '/adminDashboardScreen': (context) => const AdminDashboardScreen(),
        },
      ),
    );
  }
}

class DebugMenuScreen extends StatelessWidget {
  const DebugMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routes = {
      'Splash Screen': '/splash',
      'Auth Wrapper': '/authWrapper',
      'Authentication': '/authentication',
      'Login': '/login',
      'Register': '/register',
      'Survey': '/survey',
      'Glo Profile': '/gloProfile',
      'Dashboard': '/dashboard',
      'Admin Dashboard (Page)': '/adminDashboard',
      'Main Admin Dashboard': '/adminDashboardScreen',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Menu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: routes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, entry.value);
              },
              child: Text(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
