import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/medication_model.dart';
import 'package:glo/viewmodel/medication_viewmodel.dart';

class AddMedicationScreen extends StatefulWidget {
  final String userId;

  const AddMedicationScreen({super.key, required this.userId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  final TextEditingController doctorController =
  TextEditingController(text: "Dr. Sarah Khan");

  DateTime? startDate;
  DateTime? endDate;
  String? selectedType;

  final List<String> types = [
    "💊 Tablet",
    "🟣 Capsule",
    "🧴 Topical",
    "💉 Injection",
  ];

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    scheduleController.dispose();
    doctorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background"
              ".png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 8),
                const Text(
                  "Let’s add your medication 🩷",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                _formCard(),
                const SizedBox(height: 24),
                _saveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.pink,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Add Medication",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("💊 Medication Name"),
          _inputField(
            controller: nameController,
            hint: "Enter medication name",
          ),
          const SizedBox(height: 20),
          _label("🟣 Medication Type"),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            items: types
                .map(
                  (type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ),
            )
                .toList(),
            onChanged: (value) => setState(() => selectedType = value),
            decoration: _inputDecoration("Select type"),
          ),
          const SizedBox(height: 20),
          _label("⚖️ Dosage"),
          _inputField(
            controller: dosageController,
            hint: "e.g. 100mg, 1 tablet",
          ),
          const SizedBox(height: 20),
          _label("⏰ Schedule"),
          _inputField(
            controller: scheduleController,
            hint: "e.g. After breakfast",
          ),
          const SizedBox(height: 20),
          _label("👩‍⚕️ Doctor"),
          _inputField(
            controller: doctorController,
            hint: "Enter doctor name",
          ),
          const SizedBox(height: 20),
          _label("📅 Start Date"),
          _dateButton(
            text:
            startDate != null ? _formatDate(startDate!) : "Select start date",
            onTap: () => _pickDate(isStartDate: true),
          ),
          const SizedBox(height: 20),
          _label("📅 End Date"),
          _dateButton(
            text: endDate != null ? _formatDate(endDate!) : "Select end date",
            onTap: () => _pickDate(isStartDate: false),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.pink.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.pink, width: 1.4),
      ),
    );
  }

  Widget _dateButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: Colors.white,
          foregroundColor: Colors.pink,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.pink.shade100),
          ),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffF8A5B8),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
      ),
      onPressed: () async {
        final newMedication = MedicationModel(
          name: nameController.text.trim(),
          type: selectedType,
          dosage: dosageController.text.trim(),
          schedule: scheduleController.text.trim(),
          doctorName: doctorController.text.trim(),
          instructions: scheduleController.text.trim(),
          startDate: startDate,
          endDate: endDate,
          issuedDate: DateTime.now(),
        );

        final viewModel =
        Provider.of<MedicationViewModel>(context, listen: false);
        final navigator = Navigator.of(context);

        await viewModel.addMedication(newMedication, widget.userId);

        navigator.pop();
      },
      child: const Text(
        "💊 Save Medication",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? startDate ?? DateTime.now()
          : endDate ?? startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      if (isStartDate) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split(' ').first;
  }

  BoxDecoration _cardDecoration({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.shade100.withValues(alpha: 0.4),
          blurRadius: 8,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }
}