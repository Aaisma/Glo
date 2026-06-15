import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'view/glo_splash_screen.dart';
import 'view/navigation_icon/dashboard_page.dart';
import 'view/survey_page.dart';

// Repos
import 'repo/user_repo_impl.dart';
import 'repo/auth_repo_impl.dart';
import 'repo/period_repo_impl.dart';
import 'repo/ovulation_repo_impl.dart';
import 'repo/insights_repo_impl.dart';
import 'repo/community_repo_impl.dart';
import 'repo/insights_moderation_repo_impl.dart';
import 'repo/community_moderation_repo_impl.dart';

// ViewModels
import 'viewmodel/user_view_model.dart';
import 'viewmodel/auth_view_model.dart';
import 'viewmodel/period_view_model.dart';
import 'viewmodel/ovulation_view_model.dart';
import 'viewmodel/insight_view_model.dart';
import 'viewmodel/community_view_model.dart';
import 'viewmodel/moderation_view_model.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Pre-existing ViewModels
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo: AuthRepoImpl(), userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => PeriodViewModel(PeriodRepoImpl())),
        ChangeNotifierProvider(create: (_) => OvulationViewModel(OvulationRepoImpl())),

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
        ),
        home: const SurveyPage(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/survey': (context) => const SurveyPage(),
        },
      ),
    );
  }
}
