import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:gloclone/repo/auth_repo_impl.dart';
import 'package:gloclone/repo/user_repo_impl.dart';
import 'package:gloclone/viewmodel/auth_view_model.dart';
import 'package:gloclone/viewmodel/user_view_model.dart';

import 'package:gloclone/view/authentication/login_screen.dart';
import 'package:gloclone/view/authentication/register_screen.dart';
import 'package:gloclone/view/authentication/glo_otp.dart';
import 'package:gloclone/view/authentication/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            authRepo: AuthRepoImpl(),
            userRepo: UserRepoImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserViewModel(
            userRepo: UserRepoImpl(),
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgotPasswordOTP': (context) => const GloOtpScreen(),
        '/authWrapper': (context) => const AuthWrapper(),
      },
    );
  }
}
