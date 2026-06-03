import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'view/authentication/authentication_page.dart';
import 'view/authentication/login_screen.dart';
import 'view/authentication/register.dart';
import 'view/navigation_icon/dashboard_page.dart';
import 'view/survey_page.dart';
import 'view/glo_splash_screen.dart';
import 'viewmodel/user_view_model.dart';
import 'viewmodel/auth_view_model.dart';
import 'repo/user_repo_impl.dart';
import 'repo/auth_repo_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepoImpl>(create: (_) => AuthRepoImpl()),
        Provider<UserRepoImpl>(create: (_) => UserRepoImpl()),
        ChangeNotifierProvider(
          create: (context) => UserViewModel(
            userRepo: context.read<UserRepoImpl>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(
            authRepo: context.read<AuthRepoImpl>(),
            userRepo: context.read<UserRepoImpl>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF3E63)),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthenticationPage(),
        '/dashboard': (context) => const DashboardScreen(),
        '/survey': (context) => const SurveyPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
