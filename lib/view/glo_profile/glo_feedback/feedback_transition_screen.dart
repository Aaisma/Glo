import 'package:flutter/material.dart';
import 'feedback_experience_screen.dart';
class FeedbackTransitionScreen extends StatefulWidget {
  const FeedbackTransitionScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackTransitionScreen> createState() => _FeedbackTransitionScreenState();
}

class _FeedbackTransitionScreenState extends State<FeedbackTransitionScreen> {
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3); // Premium baby pink background

  @override
  void initState() {
    super.initState();
    // Simulate a short network save processing delay, then route to the experience screen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FeedbackExperienceScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- HEART LOADING BRAND ACCENT ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        color: gloPrimaryPink,
                        backgroundColor: gloPrimaryPink.withOpacity(0.1),
                        strokeWidth: 4,
                      ),
                    ),
                    const Text(
                      "🌸",
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // --- TRANSITION STATUS TEXT ---
                Text(
                  "Sending your thoughts...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: gloDarkText,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "We're delivering your feedback directly to our design and engineering team. Please hold on a brief moment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: gloDarkText.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}