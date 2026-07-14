import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/constants/ayd_colour.dart';
import 'login_component.dart';
import 'register_screen.dart';
import 'package:glo/view/survey_page.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';

class LoginScreen extends StatefulWidget {
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
    } catch (e, stackTrace) {
      // TEMP DEBUG: prints the real exception type + trace to console.
      // The snackbar only ever shows a generic message for anything that
      // isn't a FirebaseAuthException, so this is the only way to see
      // what's actually throwing. Remove once the real cause is fixed.
      debugPrint('LoginScreen._handleLogin real error: ${e.runtimeType} - $e');
      debugPrintStack(stackTrace: stackTrace);
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

      // AuthWrapper's authStateChanges() listener already swaps in the
      // correct screen beneath us the moment sign-in resolves — often
      // before this line even runs. That means:
      //   - if LoginScreen was pushed on top of AuthWrapper (e.g. from
      //     AuthenticationPage), AuthWrapper's child has already been
      //     rebuilt underneath, so we just need to pop back to reveal it.
      //   - if LoginScreen is the only route on the stack (e.g. reached
      //     via the named '/login' route after a sign-out), there's
      //     nothing to pop back to, so we push AuthWrapper fresh.
      //
      // Either way we use LoginScreen's OWN context (valid as long as
      // `mounted` is true) rather than delegating to widget.onAuthenticated,
      // whose closure may capture a caller's context (e.g. AuthenticationPage)
      // that AuthWrapper's rebuild has already deactivated. Calling
      // Navigator.of(context) on that stale context is what throws
      // "Looking up a deactivated widget's ancestor is unsafe".
      if (mounted) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/authWrapper', (route) => false);
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
                                  builder: (routeContext) => RegisterScreen(
                                    onRegisterSuccess: () {
                                      Navigator.of(routeContext).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const SurveyPage(),
                                        ),
                                      );
                                    },
                                    onAuthenticated: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          routeContext, '/authWrapper', (route) => false);
                                    },
                                  ),
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