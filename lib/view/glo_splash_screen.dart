import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../register.dart';
import '../dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initNavigation();
  }

  Future<void> _initNavigation() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final rememberLogin = prefs.getBool('remember_login') ?? false;

    final user = _auth.currentUser;

    Widget nextPage;

    if (user != null || rememberLogin == true) {
      nextPage = const Dashboard();
    } else {
      nextPage = const Register();
    }

    _fadeNavigate(nextPage);
  }

  void _fadeNavigate(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/splash_background.png',
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: _glowAnimation.value,
                      ),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(
                          alpha: _glowAnimation.value * 0.8,
                        ),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 260),
                Text(
                  "Glo",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB04A6B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "The Art of Cycle Wellness",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB04A6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}