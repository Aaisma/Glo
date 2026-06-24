import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/medication_model.dart';
import '../viewmodel/medication_viewmodel.dart';

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
    "💉 Injection"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Add Medication",
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Let’s add your medication 🩷",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              /// Medication Name
              const Text("💊 Medication Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter medication name",
                ),
              ),
              const SizedBox(height: 20),

              /// Medication Type Dropdown
              const Text("🟣 Medication Type",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: types
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => selectedType = value),
                decoration: const InputDecoration(
                  hintText: "Select type",
                ),
              ),
              const SizedBox(height: 20),

              /// Dosage
              const Text("⚖️ Dosage",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  hintText: "e.g. 100mg, 1 tablet",
                ),
              ),
              const SizedBox(height: 20),

              /// Schedule
              const Text("⏰ Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  hintText: "e.g. After breakfast",
                ),
              ),
              const SizedBox(height: 20),

              /// Doctor
              const Text("👩‍⚕️ Doctor",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(
                  hintText: "Enter doctor name",
                ),
              ),
              const SizedBox(height: 20),

              /// Start Date
              const Text("📅 Start Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => startDate = picked);
                  }
                },
                child: Text(
                  startDate != null
                      ? startDate!.toLocal().toString().split(' ').first
                      : "Select start date",
                  style: const TextStyle(color: Colors.pink),
                ),
              ),
              const SizedBox(height: 20),

              /// End Date
              const Text("📅 End Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => endDate = picked);
                  }
                },
                child: Text(
                  endDate != null
                      ? endDate!.toLocal().toString().split(' ').first
                      : "Select end date",
                  style: const TextStyle(color: Colors.pink),
                ),
              ),
              const SizedBox(height: 30),

              /// Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF8A5B8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final newMedication = MedicationModel(
                    name: nameController.text,
                    type: selectedType,
                    dosage: dosageController.text,
                    schedule: scheduleController.text,
                    doctorName: doctorController.text,
                    instructions: scheduleController.text,
                    startDate: startDate,
                    endDate: endDate,
                    issuedDate: DateTime.now(),
                  );

                  // Capture provider and navigator BEFORE async gap
                  final viewModel =
                  Provider.of<MedicationViewModel>(context, listen: false);
                  final navigator = Navigator.of(context);

                  await viewModel.addMedication(widget.userId as MedicationModel, newMedication as String);

                  navigator.pop(); // safe, no async gap
                },
                child: const Text("💊 Save Medication"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
