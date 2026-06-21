import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/auth_view_model.dart'; //Change to opt viewmodel.
//import '../../viewmodel/otp_viewmodel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const GloOtpScreen(),
    ),
  );
}

class GloOtpScreen extends StatelessWidget {
  const GloOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OtpPage(),
    );
  }
}

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  final String phone = '+9779800000000';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().sendOtp(phone);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios,
                        size: 18, color: Colors.black54),
                    SizedBox(width: 5),
                    Text("Back",
                        style:
                        TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    color: Colors.pink.shade400,
                    size: 45,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  "Enter OTP",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "A 6-digit code has been sent to your phone.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                      (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final success =
                    await authVM.verifyOtp(_enteredOtp);

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "OTP Verified!"
                              : (authVM.error ?? "Invalid OTP"),
                        ),
                      ),
                    );
                  },
                  child: authVM.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Verify and Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.read<AuthViewModel>().sendOtp(phone);
                  },
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}