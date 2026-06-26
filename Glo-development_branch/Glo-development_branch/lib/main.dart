  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'view/navigation_icon/insight_page.dart';
import 'view/dashboard_card/ovulation_period_page.dart';
import 'view/dashboard_card/period_tracker.dart';
import 'view/dashboard_card/log_symptoms_page.dart';

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
import 'viewmodel/image_viewmodel.dart';

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
import 'repo/Image_repo_impl.dart';

// Additional views for dev menu
import 'view/community/user/community_discussions_view.dart';
import 'view/insight/user/insights_feed_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PeriodViewModel(PeriodRepoImpl())),
        ChangeNotifierProvider(create: (_) => OvulationViewModel(OvulationRepoImpl())),
        ChangeNotifierProvider(create: (_) => TrackerNavigationViewModel()),
        ChangeNotifierProvider(create: (_) => AcneTrackerViewModel(AcneRepoImpl())),
        ChangeNotifierProvider(create: (_) => ImageViewModel(ImageRepoImpl())),

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
        home: const DevMenuPage(),
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

class DevMenuPage extends StatelessWidget {
  const DevMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Navigation Menu'),
        backgroundColor: Colors.pink,
      ),
      body: ListView(
        children: [
          _buildMenuItem(context, 'Splash Screen', const SplashScreen()),
          _buildMenuItem(context, 'Auth Wrapper (Default Flow)', const AuthWrapper()),
          _buildMenuItem(context, 'Dashboard', const DashboardScreen()),
          _buildMenuItem(context, 'Insight', const InsightsPage()),
          _buildMenuItem(context, 'Profile', const GloProfileScreen()),
          _buildMenuItem(context, 'Survey Page', const SurveyPage()),
          _buildMenuItem(context, 'Ovulation Page', const OvulationPage()),
          _buildMenuItem(context, 'Period Page', const PeriodTrackerView()),
          _buildMenuItem(context, 'Log Symptoms Page', const LogSymptomsPage(isPeriod: false)),
          _buildMenuItem(context, 'Admin Dashboard', const AdminDashboardPage()),
          _buildMenuItem(context, 'Community Feed', const CommunityDiscussionsView()),
          _buildMenuItem(context, 'Insights Feed', const InsightsFeedView()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget page) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}
