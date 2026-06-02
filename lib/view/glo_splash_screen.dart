import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_view_model.dart';
import 'authentication/login_screen.dart';
import 'navigation_icon/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final viewModel = context.read<UserViewModel>();
      viewModel.setUserId(user.uid);
      await viewModel.fetchCurrentUser();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4EC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 20),
            const Text(
              "GLO",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome to GLO App",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
