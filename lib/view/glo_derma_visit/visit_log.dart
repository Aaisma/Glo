import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LogVisitScreen extends StatefulWidget {
  const LogVisitScreen({super.key});

  @override
  State<LogVisitScreen> createState() => _LogVisitScreenState();
}

class _LogVisitScreenState extends State<LogVisitScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSaving = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOut),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MMMM d, yyyy').format(picked);
      });
    }
  }

  Future<void> _saveVisit() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_dateController.text.isEmpty ||
        _doctorController.text.isEmpty ||
        _notesController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    await _firestore.collection("visits").add({
      "date": _dateController.text,
      "doctorName": _doctorController.text,
      "notes": _notesController.text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    messenger.showSnackBar(
      const SnackBar(content: Text("Visit saved successfully 🌸")),
    );

    _dateController.clear();
    _doctorController.clear();
    _notesController.clear();

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/background1.png",
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top bar (flower removed)
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFFFF7DA4)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Log Visit",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24303F),
                        fontFamily: 'Serif',
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Record your doctor visit details 🌸",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    /// Cards
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _inputCard(
                            label: "Date of Visit",
                            hint: "Select your visit date",
                            controller: _dateController,
                            icon: Icons.calendar_month_rounded,
                            readOnly: true,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 18),
                          _inputCard(
                            label: "Doctor's Name",
                            hint: "Enter doctor's name",
                            controller: _doctorController,
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 18),
                          _inputCard(
                            label: "Visit Notes",
                            hint: "Describe your appointment...",
                            controller: _notesController,
                            icon: Icons.edit_rounded,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: InkWell(
                        onTap: _isSaving ? null : _saveVisit,
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF97B8), Color(0xFFFF7DA4)],
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
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              suffixIcon: Icon(icon, color: const Color(0xFFFF7DA4)),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
