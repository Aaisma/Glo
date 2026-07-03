import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/image_viewmodel.dart';
import '../../viewmodel/user_view_model.dart';
import '../../viewmodel/auth_view_model.dart';
import 'package:image_picker/image_picker.dart';
import '../glo_profile/personal_info_page.dart';
import 'package:image_picker/image_picker.dart';

class GloProfileScreen extends StatefulWidget {
  const GloProfileScreen({super.key});

  @override
  State<GloProfileScreen> createState() => _GloProfileScreenState();
}

class _GloProfileScreenState extends State<GloProfileScreen> {
  void _onItemTap(String title) {
    if (title == "Personal Information") {
      // Route to PersonalInformationPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PersonalInformationPage()),
      );
    } else if (title == "Delete Account") {
      _deleteAccount();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$title clicked")),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authVM = context.read<AuthViewModel>();
              final userVM = context.read<UserViewModel>();
              await authVM.signOut();
              userVM.setError(null); // Optional clear
              if (mounted) {
                // AuthWrapper will handle navigation automatically
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out")),
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final userVM = context.read<UserViewModel>();
              await userVM.deleteAccount();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account deleted")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context); // capture before await
    final vm = Provider.of<ImageViewModel>(context, listen: false);

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await vm.updateProfileImage("user123", image.path);
      messenger.showSnackBar(
        const SnackBar(content: Text("Profile image updated")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE4EC), Color(0xFFFFF6F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.pink),
                        SizedBox(width: 12),
                        Icon(Icons.notifications, color: Colors.pink),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD6E6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=47",
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Hello, Victoria\nTaking care of myself, one day at a time.",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          const Icon(Icons.favorite_border, color: Colors.pink),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // STATS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statBox("Cycle Length", "23"),
                          _statBox("Cycle Length", "28 Days"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // PREMIUM CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.pink),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Upgrade to Premium\nUnlock advanced insights and predictions.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _onItemTap("Go Premium"),
                        child: const Text("Go"),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // MENU LIST
                _menuItem(Icons.person, "Personal Information"),
                _menuItem(Icons.calendar_month, "Cycle Settings"),
                _menuItem(Icons.alarm, "Reminder"),
                _menuItem(Icons.flag, "My Goal"),
                _menuItem(Icons.help, "Help & Support"),
                _menuItem(Icons.info, "About Us"),
                _menuItem(Icons.delete_forever, "Delete Account"),

                const SizedBox(height: 20),
                // LOGOUT
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.logout, color: Colors.white),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBox(String title, String value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () => _onItemTap(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pink),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}