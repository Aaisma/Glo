import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/user_view_model.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _waterGoalController = TextEditingController();

  final Color primaryPink = const Color(0xFFFF3E63);

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    if (user != null) {
      _nameController.text = user.name;
      _ageController.text = user.actualAge?.toString() ?? "";
      _weightController.text = (user.bmi != null) ? "Update via Survey" : ""; // BMI is calculated
      _waterGoalController.text = user.waterGoal?.toString() ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      appBar: AppBar(
        title: const Text("Personal Information", style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInfoField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildInfoField("Age", _ageController, Icons.cake_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildInfoField("Water Goal (Liters)", _waterGoalController, Icons.water_drop_outlined, keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _updateProfile,
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF332B2C))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryPink),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _updateProfile() async {
    final viewModel = context.read<UserViewModel>();
    final user = viewModel.user;
    if (user != null) {
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        actualAge: int.tryParse(_ageController.text.trim()),
        waterGoal: double.tryParse(_waterGoalController.text.trim()),
        profileCompleted: true,
      );
      await viewModel.editProfile(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
        Navigator.pop(context);
      }
    }
  }
}
