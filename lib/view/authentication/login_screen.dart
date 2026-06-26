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

  // Main Theme Color
  final Color primaryPink = const Color(0xFFFF3E63);

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();

    try {
      final user = await authVM.signInWithEmail(email, password);
      if (user != null) {
        userVM.setUserId(user.uid);
        await userVM.fetchCurrentUser();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVM.error ?? "Login failed")),
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

  void loginWithGoogle() async {
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

  void loginWithFacebook() async {
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
      backgroundColor: const Color(0xFFFDECEF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Back Button
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

                // Login Title
                Text(
                  "Login",
                  style: TextStyle(
                    color: primaryPink,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Welcome Back, Lovely!",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "°｡⋆⸜ 💕 We Missed You. Time To Step In! 💕 ⸝⋆｡°",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 28),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Email",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: primaryPink,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Password",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: primaryPink,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: primaryPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Login Button
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

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "New Here, Darling? ",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Join the 'Glow'",
                      style: TextStyle(
                        color: primaryPink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton({
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