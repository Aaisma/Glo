import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:glo/view/components/top_navigation.dart';
import 'package:glo/viewmodel/profile_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';

import '../authentication/authentication_page.dart';
import 'glo_about_us_screen.dart';
import 'glo_goal_screen.dart';
import 'help_support_page.dart';
import 'personal_info_page.dart';
import 'manage_password_page.dart';
import 'package:glo/view/authentication/login_screen.dart';
import 'package:glo/view/glo_profile/glo_feedback/feedback_welcome_screen.dart';
import 'package:glo/viewmodel/period_view_model.dart';

class GloProfileScreen extends StatefulWidget {
  const GloProfileScreen({super.key});

  @override
  State<GloProfileScreen> createState() => _GloProfileScreenState();
}

class _GloProfileScreenState extends State<GloProfileScreen> {
  bool _profileLoaded = false;

  static const pink = Color(0xFFE85D8A);
  static const accentPink = Color(0xFFF86A90);
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

  String _resolvedUsername(ProfileViewModel vm) {
    final username = vm.username.trim();
    if (username.isNotEmpty && username != "glo_user") {
      return username;
    }
    return _usernameFromEmail(_authEmail);
  }

  void _editProfile() {
    final vm = context.read<ProfileViewModel>();

    showDialog(
      context: context,
      barrierDismissible: !vm.isSaving,
      builder: (dialogContext) {
        return _EditProfileDialog(
          vm: vm,
          initialName: _resolvedName(vm),
          initialUsername: _resolvedUsername(vm),
          initialBio: _resolvedBio(vm).replaceAll("\n", " "),
          onPickImage: _pickProfileImage,
        );
      },
    );
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
      _openPage(const ManagePasswordPage());
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

  bool _finishingSetup = false;

  Future<void> _finishSetup() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final userVM = context.read<UserViewModel>();

    setState(() => _finishingSetup = true);

    final success = await userVM.completeProfile();

    if (!mounted) return;
    setState(() => _finishingSetup = false);

    if (success) {
      navigator.pushNamedAndRemoveUntil('/authWrapper', (route) => false);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(userVM.error ?? 'Failed to complete setup'),
        ),
      );
    }
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
                final authVm = context.read<AuthViewModel>();

                await authVm.signOut();

                if (!mounted || !dialogContext.mounted) return;

                dialogNavigator.pop();
                navigator.pushNamedAndRemoveUntil(
                  '/authWrapper',
                  (_) => false,
                );
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
    final userVM = context.watch<UserViewModel>();
    final periodVM = context.watch<PeriodViewModel>();

    final fullName = _resolvedName(vm);
    final email = _authEmail;
    final username = _resolvedUsername(vm);
    final bio = _resolvedBio(vm);
    final imagePath = _resolvedImagePath(vm);

    final cycleDay = periodVM.cycleDay?.toString() ?? "--";
    final avgCycleLength = periodVM.analyticsResult?.averageCycleLength ?? 28;
    final cycleLengthText = "$avgCycleLength Days";

    // AuthWrapper routes brand-new users here until profileCompleted is
    // true. Existing users (profileCompleted already true) just see the
    // normal settings hub with no banner.
    final needsSetup = userVM.user != null && !userVM.user!.profileCompleted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: vm.isLoading
            ? const Center(
          child: CircularProgressIndicator(color: pink),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
            child: Column(
              children: [
                TopNavigation(isLoggedIn: true, userName: fullName),
                const SizedBox(height: 8),
                if (needsSetup) ...[
                  _FinishSetupBanner(
                    isLoading: _finishingSetup,
                    onTap: _finishingSetup ? null : _finishSetup,
                  ),
                  const SizedBox(height: 10),
                ],
                _ProfileCard(
                  fullName: fullName,
                  username: username,
                  email: email,
                  bio: bio,
                  imagePath: imagePath,
                  onImageTap: _pickProfileImage,
                  onEditTap: _editProfile,
                  cycleDay: cycleDay,
                  cycleLength: cycleLengthText,
                ),
                const SizedBox(height: 10),
                _GoalCard(
                  onTap: () => _onMenuTap("My Goal"),
                ),
                const SizedBox(height: 10),
                _MenuCard(onTap: _onMenuTap),
                const SizedBox(height: 10),
                _LogoutButton(onTap: _logout),
              ],
            ),
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
  final String cycleDay;
  final String cycleLength;

  const _ProfileCard({
    required this.fullName,
    required this.username,
    required this.email,
    required this.bio,
    required this.imagePath,
    required this.onImageTap,
    required this.onEditTap,
    required this.cycleDay,
    required this.cycleLength,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/flower.png",
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                                Icons.edit,
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                fullName,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontFamily: "Georgia",
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _GloProfileScreenState.dark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "@$username",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: _GloProfileScreenState.borderPink),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.opacity,
                    title: "Current Cycle Day",
                    value: cycleDay,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: _GloProfileScreenState.borderPink.withOpacity(0.3),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.refresh_rounded,
                    title: "Cycle Length",
                    value: cycleLength,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _GloProfileScreenState.accentPink, size: 28),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _GloProfileScreenState.accentPink,
          ),
        ),
      ],
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
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: _GloProfileScreenState.iconBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              color: _GloProfileScreenState.pink,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Goal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _GloProfileScreenState.dark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Stay consistent, feel my best & embrace every step.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: _GloProfileScreenState.pink,
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
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];

          return _MenuTile(
            data: item,
            showDivider: index != items.length - 1,
            onTap: () => onTap(item.title),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(data.icon, color: _GloProfileScreenState.pink, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _GloProfileScreenState.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: _GloProfileScreenState.pink,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: _GloProfileScreenState.borderPink.withOpacity(0.3),
            indent: 40,
          ),
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

class _FinishSetupBanner extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _FinishSetupBanner({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _GloProfileScreenState.pink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _GloProfileScreenState.borderPink),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "You're almost there! Review your profile below, then finish setup to reach your dashboard.",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _GloProfileScreenState.dark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _GloProfileScreenState.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: onTap,
                child: isLoading
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Finish Setup",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
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

class _EditProfileDialog extends StatefulWidget {
  final ProfileViewModel vm;
  final String initialName;
  final String initialUsername;
  final String initialBio;
  final VoidCallback onPickImage;

  const _EditProfileDialog({
    required this.vm,
    required this.initialName,
    required this.initialUsername,
    required this.initialBio,
    required this.onPickImage,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName);
    usernameController = TextEditingController(text: widget.initialUsername);
    bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _GloProfileScreenState.softPink,
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
                      Navigator.pop(context);
                      widget.onPickImage();
                    },
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text("Change Profile Picture"),
              style: OutlinedButton.styleFrom(
                foregroundColor: _GloProfileScreenState.pink,
                side: const BorderSide(color: _GloProfileScreenState.borderPink),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                hintText: "Enter your full name",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixText: "@",
                hintText: "Unique handle",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Bio",
                hintText: "Tell us a bit about yourself",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: _GloProfileScreenState.pink)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _GloProfileScreenState.pink),
          onPressed: isSaving
              ? null
              : () async {
                  final name = nameController.text.trim();
                  final username = usernameController.text.trim().replaceAll("@", "");
                  final bio = bioController.text.trim();

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter your name")),
                    );
                    return;
                  }

                  if (username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a username")),
                    );
                    return;
                  }

                  setState(() => isSaving = true);

                  final success = await widget.vm.saveProfile(
                    name: name,
                    username: username,
                    bio: bio.isEmpty ? ProfileViewModel.defaultBio : bio,
                  );

                  if (!mounted) return;

                  setState(() => isSaving = false);

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.vm.errorMessage ?? "Profile update failed"),
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