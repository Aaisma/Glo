import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:glo/viewmodel/otp_viewmodel.dart';

class GloOtpScreen extends StatelessWidget {
  final String phone;

  const GloOtpScreen({
    super.key,
    this.phone = '',
  });

  String _resolvePhone(BuildContext context) {
    if (phone.trim().isNotEmpty) {
      return phone.trim();
    }

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String && args.trim().isNotEmpty) {
      return args.trim();
    }

    if (args is Map && args['phone'] is String) {
      final routePhone = args['phone'] as String;
      if (routePhone.trim().isNotEmpty) {
        return routePhone.trim();
      }
    }

    return '+9779800000000';
  }

  @override
  Widget build(BuildContext context) {
    return OtpPage(
      phone: _resolvePhone(context),
    );
  }
}

class OtpPage extends StatefulWidget {
  final String phone;

  const OtpPage({
    super.key,
    required this.phone,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _enteredOtp => _controllers.map((c) => c.text.trim()).join();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sendOtp();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  Future<void> _sendOtp() async {
    final viewModel = context.read<OtpViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await viewModel.sendOtp(widget.phone);

    if (!mounted) return;

    _showMessage(messenger, viewModel.message ?? viewModel.error);

    if (success && viewModel.verified) {
      navigator.pushReplacementNamed('/home');
    }
  }

  Future<void> _verifyOtp() async {
    final viewModel = context.read<OtpViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await viewModel.verifyOtp(_enteredOtp);

    if (!mounted) return;

    _showMessage(messenger, viewModel.message ?? viewModel.error);

    if (success) {
      navigator.pushReplacementNamed('/home');
    }
  }

  Future<void> _resendOtp() async {
    final viewModel = context.read<OtpViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes.first.requestFocus();

    await viewModel.resendOtp(widget.phone);

    if (!mounted) return;

    _showMessage(messenger, viewModel.message ?? viewModel.error);
  }

  void _showMessage(
      ScaffoldMessengerState messenger,
      String? message,
      ) {
    if (message == null || message.trim().isEmpty) return;

    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OtpViewModel>(
      builder: (context, viewModel, _) {
        final loading = viewModel.loading;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF2F5),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withValues(alpha: 0.12),
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
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Text(
                      "A 6-digit code has been sent to\n${widget.phone}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
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
                          focusNode: _focusNodes[index],
                          enabled: !loading,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.pink.shade300,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }

                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
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
                        disabledBackgroundColor: Colors.pink.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: loading ? null : _verifyOtp,
                      child: loading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
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
                      onTap: loading ? null : _resendOtp,
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                          color:
                          loading ? Colors.pink.shade200 : Colors.pink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}