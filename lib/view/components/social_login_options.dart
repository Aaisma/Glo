import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/user_view_model.dart';

class SocialLoginOptions extends StatelessWidget {
  const SocialLoginOptions({super.key});

  final Color primaryPink = const Color(0xFFFF3E63);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Colors.black26,
                thickness: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Options, Darling!",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: Colors.black26,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "°✧⋆ Because One Size Never Fits All ⋆✧°",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: primaryPink,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Consumer<AuthViewModel>(
          builder: (context, authVM, child) {
            return _socialButton(
              icon: Icons.g_mobiledata,
              text: "Login with Google",
              onTap: authVM.loading ? () {} : () async {
                try {
                  await authVM.signInWithGoogle(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Google Sign-In Failed: $e")),
                    );
                  }
                }
              },
            );
          },
        ),
        const SizedBox(height: 14),
        Consumer<AuthViewModel>(
          builder: (context, authVM, child) {
            return _socialButton(
              icon: Icons.facebook,
              text: "Login with Facebook",
              onTap: authVM.loading ? () {} : () async {
                try {
                  await authVM.signInWithFacebook(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Facebook Sign-In Failed: $e")),
                    );
                  }
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: primaryPink.withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          icon,
          color: primaryPink,
          size: 24,
        ),
        label: Text(
          text,
          style: TextStyle(
            color: primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
