import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/view/authentication/auth_wrapper.dart';
import 'package:glo/view/authentication/login_screen.dart';
import 'package:provider/provider.dart';

// Firebase options
import 'firebase_options.dart';

// Repos
import 'repo/user_repo.dart';
import 'repo/user_repo_impl.dart';
import 'repo/auth_repo.dart';
import 'repo/auth_repo_impl.dart';
import 'repo/period_repo.dart';
import 'repo/period_repo_impl.dart';
import 'repo/ovulation_repo.dart';
import 'repo/ovulation_repo_impl.dart';
import 'repo/insights_repo.dart';
import 'repo/insights_repo_impl.dart';
import 'repo/community_repo.dart';
import 'repo/community_repo_impl.dart';
import 'repo/insights_moderation_repo.dart';
import 'repo/insights_moderation_repo_impl.dart';
import 'repo/community_moderation_repo.dart';
import 'repo/community_moderation_repo_impl.dart';
import 'repo/water_tracker_repo.dart';
import 'repo/water_tracker_repo_impl.dart';
import 'repo/mood_repository.dart';
import 'repo/mood_repository_impl.dart';
import 'repo/nutrition_repo.dart';
import 'repo/nutrition_repo_impl.dart';
import 'repo/acne_repo.dart';
import 'repo/acne_repo_impl.dart';
import 'repo/medication_repo.dart';
import 'repo/medication_repo_impl.dart';
import 'repo/notification_repo.dart';
import 'repo/Notification_repo_Impl.dart';

// ViewModels
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/otp_viewmodel.dart';
import 'viewmodel/period_view_model.dart';
import 'viewmodel/ovulation_view_model.dart';
import 'viewmodel/insight_view_model.dart';
import 'viewmodel/community_view_model.dart';
import 'viewmodel/wellness_viewmodel.dart';
import 'viewmodel/water_tracker_viewmodel.dart';
import 'viewmodel/nutrition_tracker_viewmodel.dart';
import 'viewmodel/medication_viewmodel.dart';
import 'viewmodel/notification_view_model.dart';
import 'viewmodel/acne_tracker_viewmodel.dart';
import 'viewmodel/profile_viewmodel.dart';
import 'viewmodel/tracker_navigation_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repos
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<AuthRepo>(create: (_) => AuthRepoImpl()),
        Provider<PeriodRepo>(create: (_) => PeriodRepoImpl()),
        Provider<OvulationRepo>(create: (_) => OvulationRepoImpl()),
        Provider<InsightsRepo>(create: (_) => InsightsRepoImpl()),
        Provider<CommunityRepo>(create: (_) => CommunityRepoImpl()),
        Provider<InsightsModerationRepo>(create: (_) => InsightsModerationRepoImpl()),
        Provider<CommunityModerationRepo>(create: (_) => CommunityModerationRepoImpl()),
        Provider<WaterTrackerRepo>(create: (_) => WaterTrackerRepoImpl()),
        Provider<MoodRepository>(create: (_) => MoodRepositoryImpl()),
        Provider<NutritionRepo>(create: (_) => NutritionRepoImpl()),
        Provider<AcneRepo>(create: (_) => AcneRepoImpl()),
        Provider<MedicationRepo>(create: (_) => MedicationRepoImpl()),
        Provider<NotificationRepo>(create: (_) => NotificationRepoImpl()),

        // ViewModels
        ChangeNotifierProvider(create: (ctx) => UserViewModel(userRepo: ctx.read<UserRepo>())),
        ChangeNotifierProvider(create: (ctx) => AuthViewModel(authRepo: ctx.read<AuthRepo>(), userRepo: ctx.read<UserRepo>())),
        ChangeNotifierProvider(create: (_) => OtpViewModel()),
        ChangeNotifierProvider(create: (ctx) => PeriodViewModel(periodRepo: ctx.read<PeriodRepo>(), ovulationRepo: ctx.read<OvulationRepo>())),
        ChangeNotifierProvider(create: (ctx) => OvulationViewModel(ovulationRepo: ctx.read<OvulationRepo>(), periodRepo: ctx.read<PeriodRepo>())),
        ChangeNotifierProvider(create: (ctx) => InsightsFeedViewModel(ctx.read<InsightsRepo>())),
        ChangeNotifierProvider(create: (ctx) => FavoritesViewModel(ctx.read<InsightsRepo>(), ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => ArticleDetailViewModel(ctx.read<InsightsRepo>(), ctx.read<InsightsModerationRepo>())),
        ChangeNotifierProvider(create: (ctx) => CommunityFeedViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => CreateDiscussionViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => CreatePollViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => DiscussionDetailViewModel(ctx.read<CommunityRepo>(), ctx.read<CommunityModerationRepo>())),
        ChangeNotifierProvider(create: (ctx) => WellnessViewModel(moodRepository: ctx.read<MoodRepository>())),
        ChangeNotifierProvider(create: (ctx) => WaterTrackerViewModel(ctx.read<WaterTrackerRepo>())),
        ChangeNotifierProvider(create: (ctx) => NutritionTrackerViewModel(ctx.read<NutritionRepo>())),
        ChangeNotifierProvider(create: (ctx) => MedicationViewModel(repo: ctx.read<MedicationRepo>())),
        ChangeNotifierProvider(create: (ctx) => NotificationViewModel(notificationRepo: ctx.read<NotificationRepo>())),
        ChangeNotifierProvider(create: (ctx) => AcneTrackerViewModel(ctx.read<AcneRepo>())),
        ChangeNotifierProvider(create: (ctx) => ProfileViewModel()),
        ChangeNotifierProvider(create: (ctx) => TrackerNavigationViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Project',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/authWrapper': (context) => const LoginScreen(),
          '/home': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}