import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/constants/ayd_colour.dart';
import 'login_component.dart';
import 'register_screen.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  /// Called once email/password (or Google/Facebook, via
  /// [LoginOptionsSection]) sign-in succeeds. Your `AuthWrapper` already
  /// listens to `FirebaseAuth.instance.authStateChanges()` and handles
  /// fetching the profile and routing to Survey / Profile / Dashboard /
  /// Admin, so just hand off to it here, e.g.:
  /// `Navigator.of(context).pushNamedAndRemoveUntil('/authWrapper', (route) => false)`.
  final VoidCallback? onAuthenticated;

  const LoginScreen({super.key, this.onAuthenticated});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    try {
      await authViewModel.login(context, email, password);
      if (mounted && authViewModel.user != null) {
        await _completeLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_friendlyAuthError(e))),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Forgot Password'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your registered email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = emailController.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(dialogContext, value);
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (email == null || email.isEmpty || !mounted) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent to your email.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset link. Please try again.')),
        );
      }
    }
  }

  String _friendlyAuthError(Object e) {
    if (e is FirebaseAuthException) {
      return e.message ?? 'Login failed. Please try again.';
    }
    return 'Login failed. Please try again.';
  }

  Future<void> _completeLogin() async {
    if (!mounted) return;
    final authViewModel = context.read<AuthViewModel>();
    final userViewModel = context.read<UserViewModel>();

    if (authViewModel.user != null) {
      // Set the user ID and fetch the latest profile data to check the role
      userViewModel.setUserId(authViewModel.user!.uid);
      await userViewModel.fetchCurrentUser();

      if (mounted) {
        if (widget.onAuthenticated != null) {
          widget.onAuthenticated!();
        } else {
          final userModel = userViewModel.user;
          // Check role and navigate accordingly
          // AuthWrapper handles the actual widget switching based on role and onboarding status
          if (userModel?.role == 'admin') {
            Navigator.of(context).pushNamedAndRemoveUntil('/authWrapper', (route) => false);
          } else {
            // Role 'user' or default
            Navigator.of(context).pushNamedAndRemoveUntil('/authWrapper', (route) => false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().loading;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF3A2A30)),
                  ),
                ),
                SizedBox(height: h * 0.01),
                const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AydColors.titlePink,
                  ),
                ),
                SizedBox(height: h * 0.02),
                const Text(
                  'Welcome Back, Lovely!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A2A30),
                  ),
                ),
                SizedBox(height: h * 0.005),
                Text(
                  '.✧♡✦ We Missed You. Time to Step In! ✦♡✧.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink.shade300,
                  ),
                ),
                SizedBox(height: h * 0.04),
                RoundedTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: h * 0.02),
                RoundedTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  trailing: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AydColors.hintGrey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                SizedBox(height: h * 0.01),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade300,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.015),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AydColors.primaryPink,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AydColors.primaryPink.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3A2A30),
                      ),
                      children: [
                        const TextSpan(text: 'New Here, Darling? '),
                        TextSpan(
                          text: 'Join the \'Glo\' (｡>ᴗ<)◈!',
                          style: TextStyle(
                            color: Colors.pink.shade400,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.03),
                LoginOptionsSection(
                  onAuthenticated: _completeLogin,
                ),
                SizedBox(height: h * 0.015),
              ],
            ),
          ),
        ),
      ),
    );
  }
}