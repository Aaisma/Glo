import 'package:flutter/material.dart';
import '../components/top_navigation.dart';
import 'login_screen.dart';
import 'register.dart';
import '../profile_pages/help_support_page.dart';
import '../profile_pages/about_us_page.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const TopNavigation(isLoggedIn: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildAuthHeader(context),
                      const SizedBox(height: 20),
                      _buildMenuSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD6E6).withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 50, color: Color(0xFFFD8CA1)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _authButton(
                      context,
                      "Log In",
                      const Color(0xFFFA4E6F
                      ),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    ),
                    const SizedBox(height: 8),
                    _authButton(
                      context,
                      "Register",
                      const Color(0xFFFA4E6F),
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white, thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _cycleStat("Current cycle Day", "--"),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.5)),
              _cycleStat("Cycle Length", "-- Days"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _authButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: onTap,
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _cycleStat(String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              label.contains("Day") ? Icons.water_drop : Icons.refresh,
              color: const Color(0xFFFF3E63),
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF332B2C))),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF332B2C)),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _menuItem(
              context,
              Icons.help_outline,
              "Help & Support",
              "Get help & contact support",
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage())),
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.info_outline,
              "About Us",
              "App version and info",
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD6E6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFFF3E63)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF332B2C),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }
}
