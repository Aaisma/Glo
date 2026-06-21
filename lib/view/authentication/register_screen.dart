import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/user_view_model.dart';
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

    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    
    userVM.setSignupCredentials(name, email, password);

    final user = await authVM.signUpWithEmail(email, password);
    if (user != null) {
      await user.updateDisplayName(name);
      await userVM.createDefaultProfile();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? "Registration failed")),
      );
    }
  }

  void registerWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    final user = await authVM.signInWithGoogle();
    if (user != null) {
      await userVM.createDefaultProfile();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? "Google sign in failed")),
      );
    }
  }

  void registerWithFacebook() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    final user = await authVM.signInWithFacebook();
    if (user != null) {
      await userVM.createDefaultProfile();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? "Facebook sign in failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      body: SafeArea(
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
                  style: TextStyle(color: primaryPink, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Hey, Lovely!",
                  style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Text("♡.･:* Your 'Glow' Begins Here! *:･.♡",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primaryPink, fontSize: 12, fontWeight: FontWeight.w500)),

              const SizedBox(height: 28),

              // Full Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Full Name",
                  prefixIcon: Icon(Icons.person_outline, color: primaryPink),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 28),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: registerUser,
                  child: const Text("Register",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 22),

              Text("Already with Us, Darling? Shine Back In ( > . < )✧!",
                  style: TextStyle(color: primaryPink, fontSize: 12, fontWeight: FontWeight.w500)),

              const SizedBox(height: 25),

              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Looking for more options?", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.black26, thickness: 1)),
                ],
              ),

              const SizedBox(height: 24),

              // Social Buttons
              SocialButton(icon: Icons.g_mobiledata, text: "Register with Google", color: primaryPink, onTap: registerWithGoogle),
              const SizedBox(height: 14),
              SocialButton(icon: Icons.facebook, text: "Register with Facebook", color: primaryPink, onTap: registerWithFacebook),
            ],
          ),
        ),
      ),
    );
  }
}
