import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: SettingsScreen()));

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildSection("Account", [
                _buildTile(Icons.person_outline, "Admin Profile", "View and edit profile"),
                _buildTile(Icons.lock_outline, "Change Password", "Update your password"),
              ]),
              _buildSection("General", [
                _buildTile(Icons.notifications_none, "Notification Settings", "Manage notifications"),
                _buildTile(Icons.shield_outlined, "Privacy & Security", "Manage privacy settings"),
                _buildTile(Icons.language, "Language", "English"),
                _buildTile(Icons.wb_sunny_outlined, "Theme", "Light"),
              ]),
              _buildSection("Data & Backup", [
                _buildTile(Icons.cloud_upload_outlined, "Backup & Restore", "Backup your data"),
                _buildTile(Icons.ios_share, "Export Data", "Export all data"),
              ]),
              _buildSection("About", [
                _buildTile(Icons.info_outline, "About Clo Journal", "Version 1.0.0"),
              ]),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return const Row(
      children: [
        Icon(Icons.arrow_back),
        SizedBox(width: 20),
        Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.pinkAccent),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }
}