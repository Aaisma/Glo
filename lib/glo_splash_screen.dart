import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glo',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // CHANGE THIS VALUE
  // true = go to homepage
  // false = go to login/signup
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {

      if (isLoggedIn) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
        );

      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD1E1),
              Color(0xFFFFC1D6),
              Color(0xFFFFDCE8),
            ],
          ),
        ),

        child: Stack(
          children: [

            // TOP GLOSS EFFECT
            Positioned(
              top: -50,
              left: -30,
              child: Container(
                width: 250,
                height: 250,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),

                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // RIGHT SPARKLE
            Positioned(
              top: 180,
              right: 50,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.8),
                size: 26,
              ),
            ),

            // LEFT SPARKLE
            Positioned(
              bottom: 220,
              left: 45,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
            ),

            // BOTTOM GLOSS EFFECT
            Positioned(
              bottom: -80,
              right: -50,
              child: Container(
                width: 320,
                height: 320,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),

                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            // MAIN CONTENT
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // APP NAME
                  const Text(
                    "Glo",
                    style: TextStyle(
                      fontSize: 78,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Color(0xFFE75D8F),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // TAGLINE
                  const Text(
                    "GLOW. LOVE. OWN.",
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: 4,
                      color: Color(0xFFE78BAA),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // HEART ICON
                  Icon(
                    Icons.favorite,
                    color: const Color(0xFFE75D8F)
                        .withValues(alpha: 0.9),
                    size: 18,
                  ),

                  const SizedBox(height: 50),

                  // LOADING INDICATOR
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}









// ================= HOME PAGE =================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD1E1),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Glo",
          style: TextStyle(
            color: Color(0xFFE75D8F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: const Center(
        child: Text(
          "Welcome to Glo ✨",
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFE75D8F),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}









// ================= LOGIN / SIGNUP PAGE =================

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "Welcome to Glo 💖",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE75D8F),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Glow with confidence.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 60),

              // LOGIN BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE75D8F),

                  minimumSize: const Size(
                    double.infinity,
                    58,
                  ),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SIGN UP BUTTON
              OutlinedButton(
                style: OutlinedButton.styleFrom(

                  side: const BorderSide(
                    color: Color(0xFFE75D8F),
                    width: 1.5,
                  ),

                  minimumSize: const Size(
                    double.infinity,
                    58,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                onPressed: () {},

                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFE75D8F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}