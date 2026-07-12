import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/view/glo_mood/wellness_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Repos
import 'package:glo/repo/user_repo.dart';
import 'package:glo/repo/user_repo_impl.dart';
import 'package:glo/repo/mood_repo.dart';
import 'package:glo/repo/mood_repo_impl.dart';

// ViewModels
import 'package:glo/viewmodel/user_viewmodel.dart';
import 'package:glo/viewmodel/mood_viewmodel.dart';

// Views
// Using a placeholder if WellnessDashboardScreen is blocked by gitignore
import 'package:glo/view/glo_mood/wellness_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserRepo>(create: (_) => UserRepoImpl()),
        Provider<MoodRepo>(create: (_) => MoodRepoImpl()),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(userRepo: context.read<UserRepo>()),
        ),
        ChangeNotifierProvider(
          create: (context) => MoodViewModel(moodRepo: context.read<MoodRepo>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Glo Mood',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const WellnessDashboardScreen(),
      ),
    );
  }
}
