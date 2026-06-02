import 'package:flutter/material.dart';

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
        _socialButton(
          icon: Icons.g_mobiledata,
          text: "Login with Google",
          onTap: () {},
        ),
        const SizedBox(height: 14),
        _socialButton(
          icon: Icons.facebook,
          text: "Login with Facebook",
          onTap: () {},
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
