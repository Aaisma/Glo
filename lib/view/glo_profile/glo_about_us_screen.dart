import 'package:flutter/material.dart';

class GloAboutUsScreen extends StatelessWidget {
  const GloAboutUsScreen({super.key});

  static const Color pink = Color(0xFFFF7FA8);
  static const Color lightPink = Color(0xFFFFF1F6);
  static const Color textDark = Color(0xFF4B4B58);

  static const String logoImage = "assets/images/logo.png";
  static const String loveImage = "assets/images/logo.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: pink, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              _heroCard(),
              const SizedBox(height: 14),
              _missionCard(),
              const SizedBox(height: 14),
              _sectionCard(
                title: "What We Believe",
                children: const [
                  _MiniInfo(
                    icon: Icons.favorite_border,
                    title: "Self-Care First",
                    description: "We believe self-care is not a luxury, it’s a necessity.",
                  ),
                  _MiniInfo(
                    icon: Icons.shield_outlined,
                    title: "Privacy & Trust",
                    description: "Your data is safe with us. Always private, always secure.",
                  ),
                  _MiniInfo(
                    icon: Icons.eco_outlined,
                    title: "Science-Backed",
                    description: "Our insights and predictions are powered by science and real data.",
                  ),
                  _MiniInfo(
                    icon: Icons.groups_outlined,
                    title: "You’re Not Alone",
                    description: "We’re here to support you on your wellness journey.",
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: "Why Glo 1.0?",
                children: const [
                  _MiniInfo(
                    icon: Icons.calendar_month_outlined,
                    title: "Accurate Tracking",
                    description: "Track your cycle, symptoms, and moods with ease.",
                  ),
                  _MiniInfo(
                    icon: Icons.bar_chart_outlined,
                    title: "Smart Insight",
                    description: "Get personalized insights and predictions.",
                  ),
                  _MiniInfo(
                    icon: Icons.notifications_none,
                    title: "Timely Reminders",
                    description: "Never miss important dates and self-care tips.",
                  ),
                  _MiniInfo(
                    icon: Icons.favorite_border,
                    title: "Holistic Wellness",
                    description: "Support your mind, body, and emotions.",
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _madeWithLoveCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      height: 205,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  logoImage,
                  height: 76,
                  width: 76,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Glo 1.0",
                  style: TextStyle(
                    fontSize: 26,
                    color: pink,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Georgia",
                  ),
                ),
                const Text(
                  "It's Glow'O Clock",
                  style: TextStyle(
                    fontSize: 8,
                    color: pink,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Your Glow, Our Mission",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Glo is your personal companion for a healthier, happier you.\n\n"
                      "We combine science and self-care to help you understand your body, "
                      "track your cycle, and embrace your glow every day.",
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: lightPink,
            child: Icon(Icons.track_changes, color: pink, size: 28),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Mission",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Empowering women with knowledge and tools to take charge of their well-being at every stage of life.",
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.45,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: pink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: child,
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _madeWithLoveCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: lightPink,
            child: Image.asset(
              loveImage,
              height: 54,
              width: 54,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Made with ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    Image.asset(
                      loveImage,
                      height: 18,
                      width: 18,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      " for You",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Glo is designed with love and passion to help you live a healthier, more confident life.",
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.45,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Thank you for being a part of our community!",
                  style: TextStyle(
                    fontSize: 10,
                    color: pink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: pink.withValues(alpha: 0.13),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MiniInfo({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: GloAboutUsScreen.pink, size: 28),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8.5,
            color: GloAboutUsScreen.pink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 7.5,
            height: 1.45,
            color: GloAboutUsScreen.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}