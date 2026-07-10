import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// View
import 'view/authentication/register_screen.dart';
import 'view/authentication/login_screen.dart';

// ViewModels & Repos
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/user_viewmodel.dart';
import 'repo/auth_repo_impl.dart';
import 'repo/user_repo_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(const RegisterTestApp());
}

class RegisterTestApp extends StatelessWidget {
  const RegisterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo: AuthRepoImpl(), userRepo: UserRepoImpl())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Register Test',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const RegisterScreen(),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          // Add other routes if needed by RegisterScreen (like /authWrapper)
          '/authWrapper': (context) => const Scaffold(body: Center(child: Text("Auth Wrapper Page"))),
        },
      ),
    );
  }
}
