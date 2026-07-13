import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/view/authentication/auth_wrapper.dart';
import 'package:glo/view/glo_splash/glo_splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Firebase options
import 'firebase_options.dart';

// Repos
import 'repo/user_repo.dart';
import 'repo/admin_monthly_tracking_repo.dart';
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
import 'repo/routine_repo.dart';
import 'repo/routine_repo_impl.dart';
import 'repo/journal_repo.dart';
import 'repo/journal_repo_impl.dart';

// ViewModels
import 'viewmodel/user_viewmodel.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/session_provider.dart';
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
import 'viewmodel/routine_viewmodel.dart';
import 'viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'viewmodel/journal_viewmodel.dart';
import 'viewmodel/journal_home_viewmodel.dart';
import 'viewmodel/write_journal_viewmodel.dart';
import 'viewmodel/search_journals_viewmodel.dart';
import 'viewmodel/journal_history_viewmodel.dart';
import 'viewmodel/favorites_viewmodel.dart';
import 'viewmodel/future_letters_viewmodel.dart';
import 'viewmodel/goal_reflection_viewmodel.dart';
import 'viewmodel/gratitude_viewmodel.dart';
import 'viewmodel/journal_calendar_viewmodel.dart';
import 'viewmodel/journal_menu_viewmodel.dart';
import 'viewmodel/physical_activity_viewmodel.dart';
import 'viewmodel/self_care_viewmodel.dart';

import 'package:glo/view/authentication/authentication_page.dart';
import 'package:glo/view/authentication/login_screen.dart';
import 'package:glo/view/authentication/register_screen.dart';
import 'package:glo/view/authentication/glo_otp.dart';

import 'package:glo/view/survey_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive and open required boxes
  await Hive.initFlutter();
  await Hive.openBox('onboarding_box');
  await Hive.openBox('hidden_content_box');

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
        Provider<RoutineRepo>(create: (_) => RoutineRepoImpl()),
        Provider<AdminMonthlyTrackingRepo>(create: (_) => AdminMonthlyTrackingRepoImpl()),
        Provider<JournalRepo>(create: (_) => JournalRepoImpl()),

        // ViewModels
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (ctx) => UserViewModel(userRepo: ctx.read<UserRepo>())),
        ChangeNotifierProvider(create: (ctx) => AuthViewModel(authRepo: ctx.read<AuthRepo>(), userRepo: ctx.read<UserRepo>())),
        ChangeNotifierProvider(create: (_) => OtpViewModel()),
        ChangeNotifierProxyProvider<SessionProvider, PeriodViewModel>(
          create: (ctx) => PeriodViewModel(periodRepo: ctx.read<PeriodRepo>(), ovulationRepo: ctx.read<OvulationRepo>()),
          update: (ctx, session, previous) => previous!..setUserId(session.userId ?? ""),
        ),
        ChangeNotifierProxyProvider<SessionProvider, OvulationViewModel>(
          create: (ctx) => OvulationViewModel(ovulationRepo: ctx.read<OvulationRepo>(), periodRepo: ctx.read<PeriodRepo>()),
          update: (ctx, session, previous) => previous!..setUserId(session.userId ?? ""),
        ),
        ChangeNotifierProvider(create: (ctx) => InsightsFeedViewModel(ctx.read<InsightsRepo>())),
        ChangeNotifierProvider(create: (ctx) => FavoritesViewModel(ctx.read<InsightsRepo>(), ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => ArticleDetailViewModel(ctx.read<InsightsRepo>(), ctx.read<InsightsModerationRepo>())),
        ChangeNotifierProvider(create: (ctx) => CommunityFeedViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => CreateDiscussionViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => CreatePollViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => MyPostsViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => EditDiscussionViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => EditPollViewModel(ctx.read<CommunityRepo>())),
        ChangeNotifierProvider(create: (ctx) => DiscussionDetailViewModel(ctx.read<CommunityRepo>(), ctx.read<CommunityModerationRepo>())),
        ChangeNotifierProvider(create: (ctx) => WellnessViewModel(moodRepository: ctx.read<MoodRepository>())),
        ChangeNotifierProxyProvider<SessionProvider, WaterTrackerViewModel>(
          create: (ctx) => WaterTrackerViewModel(ctx.read<WaterTrackerRepo>()),
          update: (ctx, session, previous) => previous!..updateUserId(session.userId),
        ),
        ChangeNotifierProxyProvider<SessionProvider, NutritionTrackerViewModel>(
          create: (ctx) => NutritionTrackerViewModel(ctx.read<NutritionRepo>()),
          update: (ctx, session, previous) => previous!..updateUserId(session.userId),
        ),
        ChangeNotifierProvider(create: (ctx) => MedicationViewModel(repo: ctx.read<MedicationRepo>())),
        ChangeNotifierProvider(create: (ctx) => NotificationViewModel(notificationRepo: ctx.read<NotificationRepo>())),
        ChangeNotifierProxyProvider<SessionProvider, AcneTrackerViewModel>(
          create: (ctx) => AcneTrackerViewModel(ctx.read<AcneRepo>()),
          update: (ctx, session, previous) => previous!..updateUserId(session.userId),
        ),
        ChangeNotifierProvider(create: (ctx) => ProfileViewModel()),
        ChangeNotifierProvider(create: (ctx) => TrackerNavigationViewModel()),
        ChangeNotifierProvider(create: (ctx) => RoutineViewModel(routineRepo: ctx.read<RoutineRepo>())),
        ChangeNotifierProvider(create: (ctx) => AdminMonthlyTrackingViewModel(ctx.read<AdminMonthlyTrackingRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalViewModel(repo: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalHomeViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => WriteJournalViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => SearchJournalsViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalHistoryViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalFavoritesViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => FutureLettersViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => GoalReflectionViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => GratitudeViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalCalendarViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalMenuViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => PhysicalActivityViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => SelfCareViewModel(repository: ctx.read<JournalRepo>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Project',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/authWrapper': (context) => const AuthWrapper(),
          '/home': (context) => const AuthWrapper(),
          '/login': (context) => LoginScreen(
            onAuthenticated: () {
              Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
            },
          ),
          '/register': (context) => RegisterScreen(
            onRegisterSuccess: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SurveyPage()));
            },
            onAuthenticated: () {
              Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
            },
          ),
          '/survey': (context) => const SurveyPage(),
          '/auth': (context) => const AuthenticationPage(),
          '/forgotPasswordOTP': (context) => const GloOtpScreen(),
        },
      ),
    );
  }
}