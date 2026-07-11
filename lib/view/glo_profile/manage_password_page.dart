import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/ayd_colour.dart';
import '../../viewmodel/profile_viewmodel.dart';

class ManagePasswordPage extends StatefulWidget {
  const ManagePasswordPage({super.key});

  @override
  State<ManagePasswordPage> createState() => _ManagePasswordPageState();
}

class _ManagePasswordPageState extends State<ManagePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~_+\-\=\^%]'));
    });
  }

  int get _strengthScore {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score;
  }

  String get _strengthText {
    switch (_strengthScore) {
      case 0:
        return "";
      case 1:
        return "Weak";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Strong";
      case 5:
        return "Very Strong";
      default:
        return "";
    }
  }

  Color get _strengthTextColor {
    switch (_strengthScore) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.green;
      case 5:
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Color(0xFF332B2C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF332B2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthBars() {
    final score = _strengthScore;

    // Mapping colors sequentially based on score
    List<Color> activeColors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.green[700]!,
    ];

    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
            decoration: BoxDecoration(
              color: score > index ? activeColors[index] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _handleSave() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final current = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please enter your current password")),
      );
      return;
    }

    // Enforce the same requirements shown in the checklist below, so the
    // UI never promises rules it doesn't actually check.
    if (_strengthScore < 5) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("New password doesn't meet all requirements yet"),
        ),
      );
      return;
    }

    if (newPassword != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    final vm = context.read<ProfileViewModel>();

    setState(() => _isSaving = true);

    final success = await vm.changePassword(
      currentPassword: current,
      newPassword: newPassword,
      confirmPassword: confirm,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? "Failed to change password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF332B2C)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: Color(0xFF332B2C),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Header Image
              Center(
                child: Image.asset(
                  'assets/images/password.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 120, child: Icon(Icons.image, size: 50, color: Colors.grey)),
                ),
              ),
              const SizedBox(height: 24),

              // Title & Subtitle
              const Text(
                "Update Your Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF332B2C),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose a strong password to\nkeep your account secure.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Inputs
              _buildPasswordField(
                label: "Current Password",
                hint: "Enter current password",
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrent = !_obscureCurrent;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                label: "New Password",
                hint: "Enter new password",
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                label: "Confirm Password",
                hint: "Confirm new password",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Requirements Box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Password Requirements",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF332B2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRequirement("At least 8 characters", _hasMinLength),
                    _buildRequirement("One uppercase letter", _hasUppercase),
                    _buildRequirement("One lowercase letter", _hasLowercase),
                    _buildRequirement("One number", _hasNumber),
                    _buildRequirement("One special character", _hasSpecialChar),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Strength Meter
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password Strength",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF332B2C),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildStrengthBars(),
              const SizedBox(height: 8),
              if (_strengthScore > 0)
                Text(
                  _strengthText,
                  style: TextStyle(
                    color: _strengthTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AydColors.ctaPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.verified_user_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    "We never share your password\nwith anyone.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}