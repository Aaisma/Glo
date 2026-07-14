import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/constants/ayd_colour.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';

/// Rounded, pink-tinted text field used across the Register/Login
/// screens (e.g. Full Name, Email, Password fields).
class RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? trailing;

  const RoundedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF3A2A30)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        hintText: hintText,
        hintStyle: const TextStyle(color: AydColors.hintGrey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.pink.shade300, size: 20),
        suffixIcon: trailing,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.pink.shade200, width: 1.2),
        ),
      ),
    );
  }
}

/// Shared "Options, Darling!" section used by both the Login and
/// Register screens (everything from the divider down to the
/// social login buttons).
///
/// Only handles the Google/Facebook sign-in itself via [AuthViewModel].
/// It deliberately does NOT touch [UserViewModel] or decide where to
/// navigate — your `AuthWrapper` already listens to
/// `FirebaseAuth.instance.authStateChanges()` and handles setting the
/// user ID, fetching/creating the Firestore profile, and routing to
/// Survey / Profile / Dashboard / Admin as appropriate. Duplicating
/// that here would just race with it. Once sign-in succeeds, call
/// [onAuthenticated] to hand off to `AuthWrapper`
/// (e.g. `Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false)`).
class LoginOptionsSection extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const LoginOptionsSection({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<LoginOptionsSection> createState() => _LoginOptionsSectionState();
}

enum _SocialProvider { google, facebook }

class _LoginOptionsSectionState extends State<LoginOptionsSection> {
  _SocialProvider? _loadingProvider;

  Future<void> _handleSocialSignIn(_SocialProvider provider) async {
    final authViewModel = context.read<AuthViewModel>();

    setState(() => _loadingProvider = provider);
    try {
      final user = provider == _SocialProvider.google
          ? await authViewModel.signInWithGoogle()
          : await authViewModel.signInWithFacebook();

      if (user == null) return; // user cancelled the native sign-in sheet

      if (mounted) widget.onAuthenticated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authViewModel.error ?? 'Something went wrong. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _loadingProvider != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: Colors.pink.shade100, thickness: 1, height: 1),
        const SizedBox(height: 22),
        const Text(
          'Options, Darling!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A2A30),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '★~✧ Because One Size Never Fits All ✧~★',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            color: Colors.pink.shade300,
          ),
        ),
        const SizedBox(height: 20),
        _SocialButton(
          label: 'Login with Google',
          isLoading: _loadingProvider == _SocialProvider.google,
          onPressed:
          isBusy ? null : () => _handleSocialSignIn(_SocialProvider.google),
          leading: _CircleBadge(
            backgroundColor: Colors.white,
            borderColor: Colors.grey.shade300,
            child: const _GoogleG(size: 16),
          ),
        ),
        const SizedBox(height: 14),
        _SocialButton(
          label: 'Login with Facebook',
          isLoading: _loadingProvider == _SocialProvider.facebook,
          onPressed: isBusy
              ? null
              : () => _handleSocialSignIn(_SocialProvider.facebook),
          leading: const _CircleBadge(
            backgroundColor: Color(0xFF1877F2),
            child: Text(
              'f',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.leading,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.pink.shade100),
            ),
            child: isLoading
                ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(AydColors.primaryPink),
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.pink.shade300,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleBadge extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color? borderColor;

  const _CircleBadge({
    required this.child,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: child,
    );
  }
}

/// Simple 4-color "G" approximation of the Google logo built from
/// text, so no external image asset is required.
class _GoogleG extends StatelessWidget {
  final double size;
  const _GoogleG({required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4285F4),
      ),
    );
  }
}