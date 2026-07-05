import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/image_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

import 'package:glo/view/navigation_icon/calendar_screen.dart';
import 'package:glo/view/navigation_icon/notification_page.dart';
import 'glo_about_us_screen.dart';

class GloProfileScreen extends StatefulWidget {
  const GloProfileScreen({super.key});

  @override
  State<GloProfileScreen> createState() => _GloProfileScreenState();
}

class _GloProfileScreenState extends State<GloProfileScreen> {
  int _currentIndex = 4;

  String _bio = "Taking care of myself,\none day at a time.";
  String? _localProfileImagePath;

  static const pink = Color(0xFFE85D8A);
  static const softPink = Color(0xFFFFF7FA);
  static const iconBg = Color(0xFFFFEAF1);
  static const borderPink = Color(0xFFFFD6E2);
  static const dark = Color(0xFF14181F);

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split("@").first;

    return "User";
  }

  void _onBottomTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CalendarScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/history');
        break;
      case 4:
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Screen not connected yet")),
        );
    }
  }

  Future<void> _pickFromGalleryOnly() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (!mounted) return;

      if (image == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text("No image selected")),
        );
        return;
      }

      setState(() {
        _localProfileImagePath = image.path;
      });

      final vm = Provider.of<ImageViewModel>(context, listen: false);
      await vm.updateProfileImage("user123", image.path);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text("Profile picture updated")),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text("Gallery failed: $e")),
      );
    }
  }

  void _editProfile() {
    final nameController = TextEditingController(text: _userName);
    final bioController = TextEditingController(text: _bio.replaceAll("\n", " "));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softPink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              fontFamily: "Georgia",
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _pickFromGalleryOnly();
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text("Change Profile Picture"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: pink,
                  side: const BorderSide(color: borderPink),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Bio"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                bioController.dispose();
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel", style: TextStyle(color: pink)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: pink),
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);

                final newName = nameController.text.trim();
                final newBio = bioController.text.trim();

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null && newName.isNotEmpty) {
                    await user.updateDisplayName(newName);
                  }

                  if (!mounted) return;

                  setState(() {
                    _bio = newBio.isEmpty
                        ? "Taking care of myself,\none day at a time."
                        : newBio;
                  });

                  nameController.dispose();
                  bioController.dispose();

                  navigator.pop();

                  messenger.showSnackBar(
                    const SnackBar(content: Text("Profile updated")),
                  );
                } catch (e) {
                  if (!mounted) return;

                  messenger.showSnackBar(
                    SnackBar(content: Text("Profile update failed: $e")),
                  );
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool isLoading = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: softPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                "Change Password",
                style: TextStyle(
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(color: pink)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: pink),
                  onPressed: isLoading
                      ? null
                      : () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(context);

                    final currentPassword =
                    currentPasswordController.text.trim();
                    final newPassword = newPasswordController.text.trim();
                    final confirmPassword =
                    confirmPasswordController.text.trim();

                    if (currentPassword.isEmpty ||
                        newPassword.isEmpty ||
                        confirmPassword.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );
                      return;
                    }

                    if (newPassword.length < 6) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password must be at least 6 characters",
                          ),
                        ),
                      );
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("New passwords do not match"),
                        ),
                      );
                      return;
                    }

                    try {
                      setDialogState(() => isLoading = true);

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null || user.email == null) {
                        throw FirebaseAuthException(
                          code: "no-user",
                          message: "No logged-in user found",
                        );
                      }

                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: currentPassword,
                      );

                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(newPassword);

                      if (!mounted) return;

                      navigator.pop();

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Password changed successfully"),
                        ),
                      );
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;

                      setDialogState(() => isLoading = false);

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            e.message ?? "Failed to change password",
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      setDialogState(() => isLoading = false);

                      messenger.showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Update",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  void _showClicked(String title) {
    if (title == "About Us") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GloAboutUsScreen()),
      );
      return;
    }

    if (title == "Change Password") {
      _changePassword();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$title clicked")),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: softPink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Logout",
            style: TextStyle(
              fontFamily: "Georgia",
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: pink)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: pink),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final dialogNavigator = Navigator.of(dialogContext);

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                dialogNavigator.pop();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.58),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Column(
                children: [
                  const TopNavigation(title: "Profile"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 188,
                    child: _ProfileCard(
                      userName: _userName,
                      bio: _bio,
                      localImagePath: _localProfileImagePath,
                      onCameraTap: _pickFromGalleryOnly,
                      onEditTap: _editProfile,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 104,
                    child: _GoalCard(onTap: () => _showClicked("My Goal")),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _MenuCard(onTap: _showClicked)),
                  const SizedBox(height: 10),
                  _LogoutButton(onTap: _logout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TopNavigation extends StatelessWidget {
  final String title;

  const TopNavigation({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          _HeaderIcon(
            width: 44,
            icon: Icons.menu_rounded,
            size: 28,
            onTap: () {},
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Georgia",
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: _GloProfileScreenState.dark,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _HeaderIcon(
                  width: 40,
                  icon: Icons.calendar_today_outlined,
                  size: 24,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CalendarScreen()),
                    );
                  },
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _HeaderIcon(
                        width: 40,
                        icon: Icons.notifications_none_rounded,
                        size: 28,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: _GloProfileScreenState.pink,
                          child: Text(
                            "3",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final double width;
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _HeaderIcon({
    required this.width,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Icon(
          icon,
          color: _GloProfileScreenState.pink,
          size: size,
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String bio;
  final String? localImagePath;
  final VoidCallback onCameraTap;
  final VoidCallback onEditTap;

  const _ProfileCard({
    required this.userName,
    required this.bio,
    required this.localImagePath,
    required this.onCameraTap,
    required this.onEditTap,
  });

  ImageProvider _getProfileImage(BuildContext context) {
    if (localImagePath != null && File(localImagePath!).existsSync()) {
      return FileImage(File(localImagePath!));
    }

    try {
      final vm = Provider.of<ImageViewModel>(context);
      final savedPathOrUrl = vm.currentImage?.url;

      if (savedPathOrUrl != null && savedPathOrUrl.isNotEmpty) {
        if (!savedPathOrUrl.startsWith("http") &&
            File(savedPathOrUrl).existsSync()) {
          return FileImage(File(savedPathOrUrl));
        }
      }
    } catch (_) {}

    return const AssetImage("assets/images/profilepicture.png");
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider imageProvider = _getProfileImage(context);

    return _SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: onCameraTap,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: imageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: GestureDetector(
                        onTap: onCameraTap,
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: _GloProfileScreenState.pink,
                          child: Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: onEditTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $userName",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "Georgia",
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: _GloProfileScreenState.dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.18,
                            color: _GloProfileScreenState.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onEditTap,
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: _GloProfileScreenState.pink,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _GloProfileScreenState.borderPink),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                const Expanded(
                  child: _StatItem(
                    icon: Icons.water_drop_outlined,
                    title: "Current Cycle Day",
                    value: "23",
                  ),
                ),
                Container(
                  width: 1,
                  height: 62,
                  color: _GloProfileScreenState.borderPink,
                ),
                const Expanded(
                  child: _StatItem(
                    icon: Icons.refresh_rounded,
                    title: "Cycle Length",
                    value: "28 Days",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _GloProfileScreenState.pink, size: 30),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: _GloProfileScreenState.dark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _GloProfileScreenState.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final VoidCallback onTap;

  const _GoalCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        children: [
          _RoundIcon(icon: Icons.track_changes_rounded, iconSize: 30),
          SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 270,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Goal",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Georgia",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _GloProfileScreenState.dark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Stay consistent, feel my best & embrace every step.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.15,
                        color: _GloProfileScreenState.dark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuData(this.icon, this.title, this.subtitle);
}

class _MenuCard extends StatelessWidget {
  final Function(String) onTap;

  const _MenuCard({required this.onTap});

  static const items = [
    _MenuData(
      Icons.person_outline_rounded,
      "Personal Information",
      "Edit your personal details",
    ),
    _MenuData(
      Icons.lock_outline_rounded,
      "Change Password",
      "Update your account password",
    ),
    _MenuData(
      Icons.notifications_none_rounded,
      "Reminders",
      "Manage reminders",
    ),
    _MenuData(
      Icons.chat_bubble_outline_rounded,
      "Feedback",
      "Share your thoughts with us",
    ),
    _MenuData(
      Icons.help_outline_rounded,
      "Help & Support",
      "Get help and contact support",
    ),
    _MenuData(
      Icons.info_outline_rounded,
      "About Us",
      "App version and info",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Expanded(
            child: _MenuTile(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              showDivider: index != items.length - 1,
              onTap: () => onTap(item.title),
            ),
          );
        }),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Row(
              children: [
                _RoundIcon(icon: icon, iconSize: 29),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 260,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontFamily: "Georgia",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _GloProfileScreenState.dark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1,
                              color: _GloProfileScreenState.dark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: _GloProfileScreenState.borderPink),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _RoundIcon({
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: _GloProfileScreenState.iconBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: _GloProfileScreenState.pink,
        size: iconSize,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F7).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _GloProfileScreenState.borderPink),
          boxShadow: [
            BoxShadow(
              color: _GloProfileScreenState.pink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: _GloProfileScreenState.pink,
              size: 26,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                "Log Out",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _GloProfileScreenState.pink,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const _SoftCard({
    required this.child,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _GloProfileScreenState.softPink.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _GloProfileScreenState.borderPink),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    return onTap == null ? card : GestureDetector(onTap: onTap, child: card);
  }
}

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border.all(color: const Color(0xFFFFD9E3)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          selectedItemColor: _GloProfileScreenState.pink,
          unselectedItemColor: Colors.black45,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          iconSize: 23,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: "Insights",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}