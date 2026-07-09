import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:glo/repo/feedback_repo.dart';
import 'package:glo/repo/feedback_repo_impl.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/admin_feedback_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FeedbackRepo>(
          create: (_) => FeedbackRepoImpl(),
        ),
        ChangeNotifierProvider<AdminFeedbackViewModel>(
          create: (context) => AdminFeedbackViewModel(
            repository: context.read<FeedbackRepo>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Glo Wellness Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const AdminFeedbackDashboardScreen(),
      ),
    );
  }
}