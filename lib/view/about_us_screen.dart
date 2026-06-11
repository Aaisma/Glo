import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "About Us",
                style: TextStyle(
                  color: const Color(0xFFF06292),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset("assets/images/flower.png", height: 80),
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildInfoCard(
                "Our Mission",
                "Empower women with personalized health tools and insights.",
                Icons.favorite,
              ),
              _buildInfoCard(
                "Meet Our Experts",
                "Our team includes top health specialists and dedicated researchers.",
                Icons.people_alt,
              ),
              const SizedBox(height: 30),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Image.asset("assets/images/logo.png", height: 100),
          const SizedBox(height: 10),
          Text(
            "Welcome to Glo 🌸",
            style: TextStyle(
              color: const Color(0xFFF06292),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "At Glo, we're dedicated to helping women understand and nurture their health, with a touch of care and science.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF06292), size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFFF06292),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(content, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Image.asset("assets/images/profilepicture.png", height: 100),
        const SizedBox(height: 10),
        Text(
          "Empowering Women, Enhancing Wellness",
          style: TextStyle(
            color: const Color(0xFFF06292),
            fontStyle: FontStyle.italic,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.home, color: Color(0xFFF06292)),
            SizedBox(width: 20),
            Icon(Icons.access_time, color: Color(0xFFF06292)),
            SizedBox(width: 20),
            Icon(Icons.favorite, color: Color(0xFFF06292)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          "Thank you for being with us!",
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
