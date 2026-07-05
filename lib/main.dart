import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/repo/feedback_repo.dart';
import 'package:glo/repo/feedback_repo_impl.dart';
import 'package:glo/viewmodel/feedback_view_model.dart';
import 'package:glo/view/glo_profile/feedback_welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GloApp());
}

class GloApp extends StatelessWidget {
  const GloApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color gloPrimaryPink = Color(0xFFFF4081);
    const Color gloDarkText = Color(0xFF2C1330);
    const Color gloBabyPinkBg = Color(0xFFFFF0F3);

    return MultiProvider(
      providers: [
        Provider<FeedbackRepo>(
          create: (_) => FeedbackRepoImpl(),
        ),
        ChangeNotifierProvider<FeedbackViewModel>(
          create: (context) => FeedbackViewModel(
            repository: context.read<FeedbackRepo>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GLO Feedback Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: gloBabyPinkBg,
          primaryColor: gloPrimaryPink,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: gloDarkText),
            titleLarge: TextStyle(color: gloDarkText, fontWeight: FontWeight.bold),
          ),
        ),
        home: const FeedbackHomeScreen(),
      ),
    );
  }
}