import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'repo/admin_analytics_repo_impl.dart';
import 'viewmodel/admin_analytics_viewmodel.dart';
import 'view/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AdminTestApp());
}

class AdminTestApp extends StatelessWidget {
  const AdminTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminAnalyticsViewModel(AdminAnalyticsRepoImpl())),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AdminDashboardScreen(),
      ),
    );
  }
}