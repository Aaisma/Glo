import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:glo/viewmodel/otp_viewmodel.dart';

class GloOtpScreen extends StatelessWidget {
  final String? phone;
  final String defaultCountryCode;

  const GloOtpScreen({
    super.key,
    this.phone,
    this.defaultCountryCode = '+977',
  });

  String? _getRouteValue(BuildContext context, String key) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map && args[key] is String) {
      final value = args[key] as String;

      if (value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  String? _resolvePhone(BuildContext context) {
    final routePhone = _getRouteValue(context, 'phone');
    final routeCountryCode = _getRouteValue(context, 'countryCode');

    final rawPhone = phone?.trim().isNotEmpty == true
        ? phone!.trim()
        : routePhone;

    if (rawPhone == null || rawPhone.trim().isEmpty) {
      return null;
    }

    final countryCode = routeCountryCode ?? defaultCountryCode;

    return _formatPhoneNumber(rawPhone, countryCode);
  }

  String _formatPhoneNumber(String value, String countryCode) {
    String phoneNumber = value
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    if (phoneNumber.startsWith('00')) {
      return '+${phoneNumber.substring(2)}';
    }

    final cleanCountryCode =
    countryCode.startsWith('+') ? countryCode : '+$countryCode';

    return '$cleanCountryCode$phoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    final resolvedPhone = _resolvePhone(context);

    if (resolvedPhone == null || resolvedPhone.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF2F5),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "Phone number is missing.\nPlease go back and enter your phone number.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return OtpPage(phone: resolvedPhone);
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

    final success = await viewModel.sendOtp(widget.phone);

    if (!mounted) return;

    _showMessage(viewModel.message ?? viewModel.error);

    if (success && viewModel.verified && viewModel.userId != null) {
      _finishOtp(viewModel.userId!);
    }
  }

  Future<void> _verifyOtp() async {
    final viewModel = context.read<OtpViewModel>();

    final success = await viewModel.verifyOtp(_enteredOtp);

    if (!mounted) return;

    _showMessage(viewModel.message ?? viewModel.error);

    if (success && viewModel.userId != null) {
      _finishOtp(viewModel.userId!);
    }
  }

  Future<void> _resendOtp() async {
    final viewModel = context.read<OtpViewModel>();

    for (final controller in _controllers) {
      controller.clear();
    }

    _focusNodes.first.requestFocus();

    await viewModel.resendOtp(widget.phone);

    if (!mounted) return;

    _showMessage(viewModel.message ?? viewModel.error);
  }

  void _finishOtp(String userId) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, userId);
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'userId': userId,
      },
    );
  }

  void _showMessage(String? message) {
    if (message == null || message.trim().isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _otpBox({
    required int index,
    required bool loading,
  }) {
    return SizedBox(
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
          LengthLimitingTextInputFormatter(1),
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

          if (_enteredOtp.length == 6) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
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
                          (index) => _otpBox(
                        index: index,
                        loading: loading,
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
                          color: loading
                              ? Colors.pink.shade200
                              : Colors.pink,
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