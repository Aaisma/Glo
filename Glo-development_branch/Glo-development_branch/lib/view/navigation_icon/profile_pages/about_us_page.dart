import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFF3E63)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About Us",
          style: TextStyle(
            color: Color(0xFFFF3E63),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  "assets/images/aboutus.png",
                  height: 120,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Glo",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF3E63),
                  ),
                ),
                const Text(
                  "Version 1.0.0",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                _buildInfoCard(
                  "Our Mission",
                  "To empower women by providing accurate cycle tracking, personalized health insights, and a supportive community to navigate their reproductive health journey with confidence.",
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  "Our Vision",
                  "A world where every woman has the tools and knowledge to understand her body and take control of her well-being.",
                ),
                const SizedBox(height: 32),
                const Divider(color: Color(0xFFFFD6E6)),
                const SizedBox(height: 16),
                const Text(
                  "© 2024 Glo App. All rights reserved.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3E63),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF332B2C),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
