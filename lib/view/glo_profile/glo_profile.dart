import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:glo/view/components/bottom_navigation.dart';
import 'package:glo/view/calendar_screen.dart';
import 'package:glo/viewmodel/profile_viewmodel.dart';

import 'glo_about_us_screen.dart';
import 'glo_goal_screen.dart';
import 'help_support_page.dart';
import 'personal_info_page.dart';
import 'package:glo/view/glo_profile/glo_feedback/feedback_welcome_screen.dart';

class GloProfileScreen extends StatefulWidget {
  const GloProfileScreen({super.key});

  @override
  State<GloProfileScreen> createState() => _GloProfileScreenState();
}

class _GloProfileScreenState extends State<GloProfileScreen> {
  final int _currentIndex = 4;
  bool _profileLoaded = false;

  static const pink = Color(0xFFE85D8A);
  static const softPink = Color(0xFFFFF7FA);
  static const iconBg = Color(0xFFFFEAF1);
  static const borderPink = Color(0xFFFFD6E2);
  static const dark = Color(0xFF14181F);

  static const defaultBio = "Taking care of myself,\none day at a time.";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_profileLoaded) return;
    _profileLoaded = true;

    context.read<ProfileViewModel>().loadProfile();
  }

  String get _authName {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    final email = user?.email?.trim();

    if (name != null && name.isNotEmpty) return name;
    if (email != null && email.isNotEmpty) return email.split("@").first;
    return "User";
  }

  String get _authEmail {
    return FirebaseAuth.instance.currentUser?.email?.trim() ?? "";
  }

  String get _authPhotoUrl {
    return FirebaseAuth.instance.currentUser?.photoURL?.trim() ?? "";
  }

  String _usernameFromEmail(String email) {
    if (email.trim().isEmpty || !email.contains("@")) return "glo_user";
    return email.split("@").first;
  }

  String _resolvedName(ProfileViewModel vm) {
    final name = vm.name.trim();

    if (name.isNotEmpty && name.toLowerCase() != "user") {
      return name;
    }

    return _authName;
  }

  String _resolvedBio(ProfileViewModel vm) {
    final bio = vm.bio.trim();

    if (bio.isNotEmpty) {
      return bio;
    }

    return defaultBio;
  }

  String? _resolvedImagePath(ProfileViewModel vm) {
    final profileImagePath = vm.profileImagePath?.trim();

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      return profileImagePath;
    }

    if (_authPhotoUrl.isNotEmpty) {
      return _authPhotoUrl;
    }

    return null;
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _onBottomTap(int index) {
    if (index == _currentIndex) return;

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CalendarScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/history');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Screen not connected yet")),
    );
  }

  Future<void> _pickProfileImage() async {
    final messenger = ScaffoldMessenger.of(context);
    final vm = context.read<ProfileViewModel>();

    try {
      final image = await ImagePicker().pickImage(
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

      final success = await vm.updateProfileImage(image.path);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Profile picture updated"
                : vm.errorMessage ?? "Profile picture update failed",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text("Gallery failed: $e")),
      );
    }
  }

  void _editProfile() {
    final vm = context.read<ProfileViewModel>();

    final nameController = TextEditingController(
      text: _resolvedName(vm),
    );

    final bioController = TextEditingController(
      text: _resolvedBio(vm).replaceAll("\n", " "),
    );

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: softPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const _DialogTitle("Edit Profile"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () {
                        Navigator.pop(dialogContext);
                        _pickProfileImage();
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
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(color: pink)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: pink),
                  onPressed: isSaving
                      ? null
                      : () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(context);

                    final name = nameController.text.trim();
                    final bio = bioController.text.trim();

                    if (name.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Please enter your name"),
                        ),
                      );
                      return;
                    }

                    setDialogState(() => isSaving = true);

                    final success = await vm.saveProfile(
                      name: name,
                      bio: bio.isEmpty ? defaultBio : bio,
                    );

                    if (!mounted || !dialogContext.mounted) return;

                    setDialogState(() => isSaving = false);

                    if (success) {
                      navigator.pop();

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated"),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            vm.errorMessage ?? "Profile update failed",
                          ),
                        ),
                      );
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      bioController.dispose();
    });
  }

  Future<void> _changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool isLoading = false;
    bool hideCurrent = true;
    bool hideNew = true;
    bool hideConfirm = true;

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
              title: const _DialogTitle("Change Password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PasswordField(
                      controller: currentController,
                      label: "Current Password",
                      obscure: hideCurrent,
                      onToggle: () {
                        setDialogState(() => hideCurrent = !hideCurrent);
                      },
                    ),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: newController,
                      label: "New Password",
                      obscure: hideNew,
                      onToggle: () {
                        setDialogState(() => hideNew = !hideNew);
                      },
                    ),
                    const SizedBox(height: 12),
                    _PasswordField(
                      controller: confirmController,
                      label: "Confirm New Password",
                      obscure: hideConfirm,
                      onToggle: () {
                        setDialogState(() => hideConfirm = !hideConfirm);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(color: pink)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: pink),
                  onPressed: isLoading
                      ? null
                      : () async {
                    final navigator = Navigator.of(dialogContext);
                    final messenger = ScaffoldMessenger.of(context);
                    final vm = context.read<ProfileViewModel>();

                    setDialogState(() => isLoading = true);

                    final success = await vm.changePassword(
                      currentPassword: currentController.text,
                      newPassword: newController.text,
                      confirmPassword: confirmController.text,
                    );

                    if (!mounted || !dialogContext.mounted) return;

                    setDialogState(() => isLoading = false);

                    if (success) {
                      navigator.pop();

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Password changed successfully",
                          ),
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            vm.errorMessage ??
                                "Failed to change password",
                          ),
                        ),
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

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  void _onMenuTap(String title) {
    if (title == "My Goal") {
      _openPage(const GoalScreen());
      return;
    }

    if (title == "Personal Information") {
      _openPage(const PersonalInformationPage());
      return;
    }

    if (title == "Change Password") {
      _changePassword();
      return;
    }

    if (title == "Feedback") {
      _openPage(const FeedbackHomeScreen());
      return;
    }

    if (title == "Help & Support") {
      _openPage(const HelpSupportPage());
      return;
    }

    if (title == "About Us" || title == "About Glo") {
      _openPage(const GloAboutUsScreen());
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const _DialogTitle("Logout"),
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
                final vm = context.read<ProfileViewModel>();

                await vm.logout();

                if (!mounted || !dialogContext.mounted) return;

                dialogNavigator.pop();
                navigator.pushNamedAndRemoveUntil('/login', (_) => false);
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    final fullName = _resolvedName(vm);
    final email = _authEmail;
    final username = _usernameFromEmail(email);
    final bio = _resolvedBio(vm);
    final imagePath = _resolvedImagePath(vm);

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
            child: vm.isLoading
                ? const Center(
              child: CircularProgressIndicator(color: pink),
            )
                : Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Column(
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 188,
                    child: _ProfileCard(
                      fullName: fullName,
                      username: username,
                      email: email,
                      bio: bio,
                      imagePath: imagePath,
                      onImageTap: _pickProfileImage,
                      onEditTap: _editProfile,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 104,
                    child: _GoalCard(
                      onTap: () => _onMenuTap("My Goal"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _MenuCard(onTap: _onMenuTap)),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 52,
      child: Center(
        child: Text(
          "Profile",
          style: TextStyle(
            fontFamily: "Georgia",
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _GloProfileScreenState.dark,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String fullName;
  final String username;
  final String email;
  final String bio;
  final String? imagePath;
  final VoidCallback onImageTap;
  final VoidCallback onEditTap;

  const _ProfileCard({
    required this.fullName,
    required this.username,
    required this.email,
    required this.bio,
    required this.imagePath,
    required this.onImageTap,
    required this.onEditTap,
  });

  ImageProvider _profileImage() {
    final path = imagePath?.trim();

    if (path != null && path.isNotEmpty) {
      if (path.startsWith("http")) {
        return NetworkImage(path);
      }

      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }

    return const AssetImage("assets/images/profilepicture.png");
  }

  @override
  Widget build(BuildContext context) {
    final cleanEmail = email.trim();

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
                      onTap: onImageTap,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: _profileImage(),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 1,
                      child: GestureDetector(
                        onTap: onImageTap,
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
                    borderRadius: BorderRadius.circular(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $fullName",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "Georgia",
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _GloProfileScreenState.dark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "@$username",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _GloProfileScreenState.dark,
                          ),
                        ),
                        if (cleanEmail.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            cleanEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _GloProfileScreenState.dark,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          bio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.18,
                            color: _GloProfileScreenState.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onEditTap,
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: _GloProfileScreenState.pink,
                    size: 28,
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
            style: const TextStyle(
              fontSize: 12,
              color: _GloProfileScreenState.dark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
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
            child: _CardText(
              title: "My Goal",
              subtitle: "Stay consistent, feel my best & embrace every step.",
              titleSize: 24,
              subtitleSize: 13,
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
  final ValueChanged<String> onTap;

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
              data: item,
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
  final _MenuData data;
  final bool showDivider;
  final VoidCallback onTap;

  const _MenuTile({
    required this.data,
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
                _RoundIcon(icon: data.icon, iconSize: 29),
                const SizedBox(width: 14),
                Expanded(
                  child: _CardText(
                    title: data.title,
                    subtitle: data.subtitle,
                    titleSize: 20,
                    subtitleSize: 11,
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

class _CardText extends StatelessWidget {
  final String title;
  final String subtitle;
  final double titleSize;
  final double subtitleSize;

  const _CardText({
    required this.title,
    required this.subtitle,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 270,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "Georgia",
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: _GloProfileScreenState.dark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subtitleSize,
                height: 1.1,
                color: _GloProfileScreenState.dark,
              ),
            ),
          ],
        ),
      ),
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
            Text(
              "Log Out",
              style: TextStyle(
                color: _GloProfileScreenState.pink,
                fontSize: 19,
                fontWeight: FontWeight.bold,
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

class _DialogTitle extends StatelessWidget {
  final String text;

  const _DialogTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: "Georgia",
        fontWeight: FontWeight.bold,
        color: _GloProfileScreenState.dark,
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    );
  }
}