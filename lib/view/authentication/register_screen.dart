import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodel/auth_viewmodel.dart';
import '../../viewmodel/user_viewmodel.dart';
import '../components/social_button.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  final Color primaryPink = const Color(0xFFFF3E63);

  void registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final userVM = context.read<UserViewModel>();

    try {
      await userVM.clearOnboardingProgress();
      userVM.setSignupCredentials(name, email, password);

      if (mounted) {
        Navigator.pushNamed(context, '/survey');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void registerWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    try {
      final user = await authVM.signInWithGoogle();
      if (user != null) {
        userVM.setUserId(user.uid);
        await userVM.createDefaultProfile();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVM.error ?? "Google sign in failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void registerWithFacebook() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    try {
      final user = await authVM.signInWithFacebook();
      if (user != null) {
        userVM.setUserId(user.uid);
        await userVM.createDefaultProfile();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVM.error ?? "Facebook sign in failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF), // White at top
              Color(0xFFFDECEF), // Light pink at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 20),
                  ),
                ),
                
                const SizedBox(height: 10),

                Text("Register",
                    style: TextStyle(color: primaryPink, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Hey, Lovely!",
                    style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Text("♡.･:* Your 'Glow' Begins Here! *:･.♡",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryPink, fontSize: 13, fontWeight: FontWeight.w500)),

                const SizedBox(height: 32),

                // Full Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Full Name",
                    prefixIcon: Icon(Icons.person_outline, color: primaryPink),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),

                // Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail_outline, color: primaryPink),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),

                // Password
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock_outline, color: primaryPink),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: registerUser,
                    child: const Text("Register",
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      children: [
                        const TextSpan(
                          text: "Already with Us, Darling? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: "Shine Back In ( > . < )✧!",
                          style: TextStyle(color: primaryPink, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Options, Darling! Divider
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Options, Darling!", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                  ],
                ),

                const SizedBox(height: 12),
                
                Text("⋆✧⋆ Because One Size Never Fits All ⋆✧⋆",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: primaryPink, fontSize: 12, fontWeight: FontWeight.w600)),

                const SizedBox(height: 28),

                // Social Buttons
                SocialButton(icon: Icons.g_mobiledata, text: "Login with Google", color: primaryPink, onTap: registerWithGoogle),
                const SizedBox(height: 16),
                SocialButton(icon: Icons.facebook, text: "Login with Facebook", color: primaryPink, onTap: registerWithFacebook),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
