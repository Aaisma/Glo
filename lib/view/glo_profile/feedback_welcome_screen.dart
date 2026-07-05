import 'package:flutter/material.dart';
import 'package:glo/view/glo_profile/feedback_rating_screen.dart';

class FeedbackHomeScreen extends StatelessWidget {
  const FeedbackHomeScreen({super.key});

  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: gloDarkText, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "GLO",
          style: TextStyle(
            color: gloPrimaryPink,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                "Your voice\nmakes GLO better 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: gloDarkText,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Help us improve your wellness journey and make GLO more meaningful for every woman.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: gloDarkText.withOpacity(0.6),
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/images/women_heart.png',
                  height: 250,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("👩‍🦰💖🌸", style: TextStyle(fontSize: 64));
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(
                context,
                label: "Give Feedback",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FeedbackRatingScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildBenefitsCard(),
              const SizedBox(height: 32),
              Text(
                "Every feedback is a step towards\nempowering women 🌸",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: gloDarkText.withOpacity(0.4),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gloPrimaryPink.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: gloPrimaryPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Your feedback helps us",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: gloDarkText,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureIcon("🌱", "Improve\nfeatures"),
              _buildFeatureIcon("⚙️", "Fix\nissues"),
              _buildFeatureIcon("✨", "Create better\nexperience"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(String icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: gloDarkText.withOpacity(0.7),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
