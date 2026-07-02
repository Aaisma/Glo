import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController _medicine = TextEditingController();
  final TextEditingController _dosage = TextEditingController();
  final TextEditingController _frequency = TextEditingController();
  final TextEditingController _doctor = TextEditingController();

  static const Color pink = Color(0xFFFF7DA4);
  static const Color dark = Color(0xFF24303F);
  static const Color softPink = Color(0xFFFFEFF4);

  @override
  void dispose() {
    _medicine.dispose();
    _dosage.dispose();
    _frequency.dispose();
    _doctor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background1.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBackButton(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prescription",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: dark,
                            fontFamily: 'Serif',
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Manage your prescriptions efficiently\nand keep your treatment organized ♡",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _addPrescriptionCard(context),
                        const SizedBox(height: 25),
                        const Text(
                          "My Prescriptions",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(child: _prescriptionList()),
                        const SizedBox(height: 18),
                        _saveVisitButton(context),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _circleButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: pink, size: 18),
        onPressed: onTap,
      ),
    );
  }

  Widget _addPrescriptionCard(BuildContext context) {
    return InkWell(
      onTap: () => _showAddBox(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _iconBox(Icons.receipt_long_outlined),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Prescription",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: dark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Store medicine, dosage, frequency, and doctor details",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _prescriptionList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("prescriptions")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: pink),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState();
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return _prescriptionCard(
              medicine: data["medicineName"] ?? "",
              dosage: data["dosage"] ?? "",
              frequency: data["frequency"] ?? "",
              doctor: data["doctor"] ?? "",
            );
          }).toList(),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              color: pink,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              "No prescriptions yet.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveVisitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF97B8), pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "Save Visit",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _prescriptionCard({
    required String medicine,
    required String dosage,
    required String frequency,
    required String doctor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(Icons.medication_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$dosage • $frequency",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Prescribed by: $doctor",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: softPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: pink, size: 30),
    );
  }

  void _showAddBox(BuildContext context) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF7F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Prescription 🌸",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: dark,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 18),
              _field("Medicine Name", _medicine),
              _field("Dosage", _dosage),
              _field("Frequency", _frequency),
              _field("Doctor", _doctor),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pink,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    if (_medicine.text.trim().isEmpty ||
                        _dosage.text.trim().isEmpty ||
                        _frequency.text.trim().isEmpty ||
                        _doctor.text.trim().isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection("prescriptions")
                        .add({
                      "medicineName": _medicine.text.trim(),
                      "dosage": _dosage.text.trim(),
                      "frequency": _frequency.text.trim(),
                      "doctor": _doctor.text.trim(),
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                    navigator.pop();

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text("Prescription saved"),
                      ),
                    );

                    _medicine.clear();
                    _dosage.clear();
                    _frequency.clear();
                    _doctor.clear();
                  },
                  child: const Text(
                    "Save Prescription",
                    style: TextStyle(
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

  Widget _field(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}