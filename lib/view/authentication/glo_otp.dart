import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:glo/repo/auth_repo_impl.dart';
import 'package:glo/repo/user_repo_impl.dart';
import 'package:glo/viewmodel/auth_viewmodel.dart';
import 'package:glo/viewmodel/user_viewmodel.dart';
import 'package:glo/viewmodel/otp_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo: AuthRepoImpl(), userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => UserViewModel(userRepo: UserRepoImpl())),
        ChangeNotifierProvider(create: (_) => OtpViewModel()), // Added missing provider
      ],
      child: const MaterialApp(home: GloOtpScreen()),
    ),
  );
}

class GloOtpScreen extends StatelessWidget {
  final String phone;
  const GloOtpScreen({super.key, this.phone = ''});

  String _resolvePhone(BuildContext context) {
    if (phone.trim().isNotEmpty) return phone.trim();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) return args.trim();
    if (args is Map && args['phone'] is String) return args['phone'] as String;
    return '+9779800000000';
  }

  @override
  Widget build(BuildContext context) {
    return OtpPage(phone: _resolvePhone(context));
  }
}

class OtpPage extends StatefulWidget {
  final String phone;
  const OtpPage({super.key, required this.phone});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _enteredOtp => _controllers.map((c) => c.text.trim()).join();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  Future<void> _sendOtp() async {
    final viewModel = context.read<OtpViewModel>();
    await viewModel.sendOtp(widget.phone);
    if (!mounted) return;
    _showMessage(viewModel.message ?? viewModel.error);
  }

  Future<void> _verifyOtp() async {
    final viewModel = context.read<OtpViewModel>();
    final success = await viewModel.verifyOtp(_enteredOtp);
    if (!mounted) return;
    _showMessage(viewModel.message ?? viewModel.error);
    if (success) Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _resendOtp() async {
    final viewModel = context.read<OtpViewModel>();
    for (var c in _controllers) c.clear();
    _focusNodes.first.requestFocus();
    await viewModel.resendOtp(widget.phone);
    if (!mounted) return;
    _showMessage(viewModel.message ?? viewModel.error);
  }

  void _showMessage(String? message) {
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
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
                children: [
                  // ... (Keep your existing UI elements here: Back Button, Icon, Text)

                  // Verification Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => SizedBox(
                      width: 45, height: 55,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        enabled: !loading,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(counterText: "", filled: true, fillColor: Colors.white),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
                          if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 35),

                  // Verify Button
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: loading ? null : _verifyOtp,
                      child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Verify and Continue"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend Link
                  GestureDetector(
                    onTap: loading ? null : _resendOtp,
                    child: Text("Resend Code", style: TextStyle(color: loading ? Colors.grey : Colors.pink)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}