import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/user_view_model.dart';
import '../../model/user_model.dart';

import '../authentication/login_screen.dart';
import '../authentication/register_screen.dart';
import '../authentication/logout.dart';

import '../components/top_navigation.dart';

import '../glo_profile/help_support_page.dart';
import '../glo_profile/glo_about_us_screen.dart';
import '../glo_profile/personal_info_page.dart';
import '../glo_profile/cycle_setting_page.dart';
import '../glo_profile/my_goal_page.dart';

import 'notification_page.dart';
import '../dashboard_card/admin/admin_dashboard_page.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          child: Consumer<UserViewModel>(
            builder: (context, viewModel, child) {
              final user = viewModel.user;
              final isLoggedIn = user != null;

              if (viewModel.loading && user == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFD8CA1)),
                );
              }

              return Column(
                children: [
                  const TopNavigation(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _buildProfileHeader(context, viewModel),
                          const SizedBox(height: 20),
                          _buildPremiumCard(context),
                          const SizedBox(height: 20),
                          _buildMenuSection(context, isLoggedIn),
                          if (isLoggedIn) ...[
                            const SizedBox(height: 20),
                            _buildLogoutButton(context),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserViewModel viewModel) {
    final user = viewModel.user;
    final isLoggedIn = user != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD6E6).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage: isLoggedIn 
                  ? const AssetImage("assets/images/profile picture.png")
                  : null,
                child: !isLoggedIn 
                  ? const Icon(Icons.person, size: 50, color: Color(0xFFFD8CA1))
                  : null,
              ),
              const SizedBox(width: 16),
              if (isLoggedIn)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hello, ${user.name}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF332B2C),
                            ),
                          ),
                          const Icon(Icons.favorite_border, color: Color(0xFFFF3E63)),
                        ],
                      ),
                      const Text(
                        "Taking care of myself,\none day at a time.",
                        style: TextStyle(fontSize: 14, color: Color(0xFF332B2C)),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      _authButton(
                        context, 
                        "Log In", 
                        const Color(0xFFFD8CA1), 
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      ),
                      const SizedBox(height: 8),
                      _authButton(
                        context, 
                        "Register", 
                        const Color(0xFFFD8CA1),
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
              _cycleStat("Current cycle Day", _calculateCycleDay(user)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.5)),
              _cycleStat("Cycle Length", isLoggedIn ? "28 Days" : "-- Days"),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateCycleDay(UserModel? user) {
    if (user?.lastCycleDate == null) return "--";
    final diff = DateTime.now().difference(user!.lastCycleDate!).inDays;
    return (diff + 1).toString();
  }

  Widget _authButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
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

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_border, color: Color(0xFFFF3E63), size: 40),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upgrade to Premium",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF3E63)),
                ),
                Text(
                  "Unlock advanced insight, themes, and personalized predictions",
                  style: TextStyle(fontSize: 14, color: Color(0xFF332B2C)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFD8CA1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Go Premium", style: TextStyle(fontSize: 11)),
                Icon(Icons.keyboard_double_arrow_right, size: 14),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, bool isLoggedIn) {
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
              Icons.person_outline,
              "Personal Information",
              "Edit Your Personal Edits",
              isLoggedIn,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.refresh,
              "Cycle Setting",
              "Manage your Cycle & period",
              isLoggedIn,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.notifications_none,
              "Reminder",
              "Manage reminder & Starts",
              true,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.cloud_outlined,
              "My Goal",
              "Create your goal",
              true,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.help_outline,
              "Help & Support",
              "Get help & contact support",
              true,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.info_outline,
              "About Us",
              "App version and info",
              true,
            ),
            const Divider(height: 1, indent: 70),
            _menuItem(
              context,
              Icons.admin_panel_settings_outlined,
              "Admin Portal",
              "Access Insights and Content Moderation",
              true,
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
    bool enabled
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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: enabled ? const Color(0xFF332B2C) : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: !enabled ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey) : null,
      onTap: () {
        if (!enabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please Login to access this feature")),
          );
        } else {
          switch (title) {
            case "Personal Information":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInformationPage()));
              break;
            case "Cycle Setting":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CycleSettingsPage()));
              break;
            case "Reminder":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
              break;
            case "My Goal":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyGoalPage()));
              break;
            case "Help & Support":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportPage()));
              break;
            case "About Us":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GloAboutUsScreen()));
              break;
            case "Admin Portal":
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
              break;
          }
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => LogoutDialog.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6F8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFFFD6E6)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Log Out",
              style: TextStyle(
                color: Color(0xFFFD8CA1),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.logout, color: Color(0xFFFD8CA1)),
          ],
        ),
      ),
    );
  }
}


