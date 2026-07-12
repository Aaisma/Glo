import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Firebase options
import 'firebase_options.dart';

// Repositories
import 'package:glo/repo/user_repo.dart';
import 'package:glo/repo/user_repo_impl.dart';
import 'package:glo/repo/journal_repo.dart';
import 'package:glo/repo/journal_repo_impl.dart';

// ViewModels
import 'package:glo/viewmodel/user_viewmodel.dart';
import 'package:glo/viewmodel/journal_home_viewmodel.dart';
import 'package:glo/viewmodel/journal_menu_viewmodel.dart';
import 'package:glo/viewmodel/write_journal_viewmodel.dart';
import 'package:glo/viewmodel/journal_history_viewmodel.dart';
import 'package:glo/viewmodel/search_journals_viewmodel.dart';
import 'package:glo/viewmodel/journal_calendar_viewmodel.dart';
import 'package:glo/viewmodel/future_letters_viewmodel.dart';
import 'package:glo/viewmodel/goal_reflection_viewmodel.dart';
import 'package:glo/viewmodel/physical_activity_viewmodel.dart';
import 'package:glo/viewmodel/gratitude_viewmodel.dart';
import 'package:glo/viewmodel/self_care_viewmodel.dart';
import 'package:glo/viewmodel/favorites_viewmodel.dart';

// Views
import 'package:glo/view/glo_journal/JournalHomeScreen.dart';

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
        // --- 1. Repositories ---
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<JournalRepo>(create: (_) => JournalRepoImpl()),

        // --- 2. Journal ViewModels ---
        ChangeNotifierProvider(create: (ctx) => UserViewModel(userRepo: ctx.read<UserRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalHomeViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalMenuViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => WriteJournalViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalHistoryViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => SearchJournalsViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => JournalCalendarViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => FutureLettersViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => GoalReflectionViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => PhysicalActivityViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => GratitudeViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => SelfCareViewModel(repository: ctx.read<JournalRepo>())),
        ChangeNotifierProvider(create: (ctx) => FavoritesViewModel(repository: ctx.read<JournalRepo>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Journal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
        ),
        home: const JournalHomeScreen(),
      ),
    );
  }
}
