// login_screen.dart
// Add this file inside lib/screens/login_screen.dart

import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F7),
      body: SafeArea(
        child: Row(
          children: [

            // LEFT SIDE
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(30),
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        // LOGO
                        Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffFF6FA5),
                                Color(0xffFF3D7F),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                            size: 55,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7A1E43),
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "Login to continue your",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xff7A1E43),
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          "hormonal wellness journey",
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xffFF4F8B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // EMAIL
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: Color(0xffFF4F8B),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xffFF4F8B),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: Color(0xffFFD3E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: Color(0xffFFD3E0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // PASSWORD
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: Color(0xffFF4F8B),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: passwordController,
                          obscureText: isPasswordHidden,
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xffFF4F8B),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordHidden = !isPasswordHidden;
                                });
                              },
                              icon: Icon(
                                isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: Color(0xffFFD3E0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide(
                                color: Color(0xffFFD3E0),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xffFF4F8B),
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffFF4F8B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            onPressed: () {

                              String email = emailController.text;
                              String password =
                                  passwordController.text;

                              print(email);
                              print(password);
                            },
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                "OR",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // GOOGLE
                        socialButton(
                          icon: Icons.g_mobiledata,
                          text: "Continue with Google",
                        ),

                        const SizedBox(height: 20),

                        // APPLE
                        socialButton(
                          icon: Icons.apple,
                          text: "Continue with Apple",
                        ),

                        const SizedBox(height: 35),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xffFF4F8B),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // RIGHT SIDE
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text(
                      "Understand your body.\n\nBalance your hormones.",
                      style: TextStyle(
                        fontSize: 28,
                        color: Color(0xff7A1E43),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Live your best ",
                            style: TextStyle(
                              fontSize: 38,
                              color: Color(0xff7A1E43),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "flow.",
                            style: TextStyle(
                              fontSize: 38,
                              color: Color(0xffFF4F8B),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    Container(
                      height: 420,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xffFFD3E0),
                            Color(0xffFFF5F7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.self_improvement,
                          size: 220,
                          color: Color(0xffFF4F8B),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [

                        featureItem(
                          Icons.calendar_month,
                          "Track\nYour Cycle",
                        ),

                        featureItem(
                          Icons.water_drop,
                          "Balance\nYour Hormones",
                        ),

                        featureItem(
                          Icons.spa,
                          "Improve\nYour Wellness",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget socialButton({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xffFFD3E0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 35),
          SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget featureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            size: 35,
            color: Color(0xffFF4F8B),
          ),
        ),
        SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xff7A1E43),
          ),
        ),
      ],
    );
  }
}