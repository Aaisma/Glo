import 'package:flutter/material.dart';

class AddMedicationScreen extends StatelessWidget {
  const AddMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add Medication",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Fill out the details to add your medication ❤️",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              const SizedBox(height: 20),

              /// FORM FIELDS
              buildTextField("Medication Name", "e.g., Doxycycline 100mg"),
              buildDropdownField("Medication Type", ["Antibiotic", "Supplement", "Topical"]),
              buildTextField("Dosage", "e.g., 100mg, 1 tablet"),
              buildTextField("Schedule", "e.g., After breakfast"),
              buildTextField("Doctor", "Dr. Sarah Khan"),
              buildDateField("Start Date", "Apr 01, 2026"),
              buildDateField("End Date", "Apr 15, 2026"),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save Medication",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper Widgets
  Widget buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: label, border: InputBorder.none),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget buildDateField(String label, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          hintText: date,
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.pink),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
