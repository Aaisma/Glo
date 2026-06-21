import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth_view_model.dart';
import '../../viewmodel/user_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  final Color primaryPink = const Color(0xFFFF3E63);

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();

    final user = await authVM.signInWithEmail(email, password);
    if (user != null) {
      await userVM.fetchCurrentUser();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? "Login failed")),
      );
    }
  }

  void loginWithGoogle() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    final user = await authVM.signInWithGoogle();
    if (user != null) {
      await userVM.createDefaultProfile(); // Validates and creates doc if missing
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.error ?? "Google sign in failed")),
      );
    }
  }

  void loginWithFacebook() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    final user = await authVM.signInWithFacebook();
    if (user != null) {
      await userVM.createDefaultProfile(); // Validates and creates doc if missing
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Login", style: TextStyle(color: primaryPink, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text("Welcome Back, Lovely!", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(":♡.･:* We Missed You. Time to Step In.! *:･.♡:", textAlign: TextAlign.center, style: TextStyle(color: primaryPink, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    prefixIcon: Icon(Icons.mail_outline, color: primaryPink),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),
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
                      icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: loginUser,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New Here, Darling? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text("Join the 'Glo'!", style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Colors.black26,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Options, Darling!",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 24),

                // Google Button
                socialButton(
                  icon: Icons.g_mobiledata,
                  text: "Login with Google",
                  onTap: loginWithGoogle,
                ),

                const SizedBox(height: 14),

                // Facebook Button
                socialButton(
                  icon: Icons.facebook,
                  text: "Login with Facebook",
                  onTap: loginWithFacebook,
                ),

                const SizedBox(height: 30),
                const SocialLoginOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
