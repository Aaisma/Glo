import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/constants/ayd_colour.dart';
import 'login_component.dart';
import 'login_screen.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  /// Called for the manual email/password path once signup credentials
  /// are cached via `UserViewModel.setSignupCredentials`. No Firebase
  /// account exists yet at this point (it's only created later in
  /// `finalizeOnboarding()`), so `AuthWrapper` can't help here — wire
  /// this directly to `SurveyPage`.
  final VoidCallback? onRegisterSuccess;

  /// Called once a Google/Facebook sign-up succeeds (via
  /// [LoginOptionsSection]). This *does* create a real Firebase account
  /// immediately, so — same as [LoginScreen.onAuthenticated] — just hand
  /// off to `AuthWrapper`; it will show `SurveyPage` for a brand-new
  /// account or go straight to the dashboard for one that's already
  /// fully set up, e.g.:
  /// `Navigator.of(context).pushNamedAndRemoveUntil('/authWrapper', (route) => false)`.
  final VoidCallback? onAuthenticated;

  const RegisterScreen({
    super.key,
    this.onRegisterSuccess,
    this.onAuthenticated,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields, darling!')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    // Manual registration doesn't create the Firebase account yet — it's
    // cached here and only created later in
    // UserViewModel.finalizeOnboarding() once the skin survey is complete.
    context.read<UserViewModel>().setSignupCredentials(name, email, password);

    widget.onRegisterSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AydColors.titlePink,
                  ),
                ),
                SizedBox(height: h * 0.02),
                const Text(
                  'Hey, Lovely!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A2A30),
                  ),
                ),
                SizedBox(height: h * 0.005),
                Text(
                  '.✧♡✦ Your \'Glo\' Begins Here! ✦♡✧.',
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
                  controller: _fullNameController,
                  hintText: 'Full Name',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: h * 0.02),
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
                SizedBox(height: h * 0.035),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AydColors.primaryPink,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AydColors.primaryPink.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Register',
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
                        const TextSpan(text: 'Already with Us, Darling? '),
                        TextSpan(
                          text: 'Shine Back In (｡>ᴗ<)◈!',
                          style: TextStyle(
                            color: Colors.pink.shade400,
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
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
                  onAuthenticated: () {
                    widget.onAuthenticated?.call();
                  },
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