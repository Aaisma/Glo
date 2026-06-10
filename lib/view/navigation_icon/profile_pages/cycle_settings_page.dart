import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:glo/viewmodel/user_view_model.dart';

class CycleSettingsPage extends StatefulWidget {
  const CycleSettingsPage({super.key});

  @override
  State<CycleSettingsPage> createState() => _CycleSettingsPageState();
}

class _CycleSettingsPageState extends State<CycleSettingsPage> {
  DateTime? _lastCycleDate;
  final Color primaryPink = const Color(0xFFFF3E63);

  @override
  void initState() {
    super.initState();
    _lastCycleDate = context.read<UserViewModel>().user?.lastCycleDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      appBar: AppBar(
        title: const Text("Cycle Settings", style: TextStyle(color: Color(0xFF332B2C), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Last Period Start Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: primaryPink),
                    const SizedBox(width: 12),
                    Text(
                      _lastCycleDate == null ? "Select Date" : DateFormat('MMMM dd, yyyy').format(_lastCycleDate!),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPink,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _saveSettings,
                child: const Text("Update Cycle Info", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _lastCycleDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _lastCycleDate = date);
  }

  void _saveSettings() async {
    final viewModel = context.read<UserViewModel>();
    final user = viewModel.user;
    if (user != null) {
      final updatedUser = user.copyWith(lastCycleDate: _lastCycleDate);
      await viewModel.editProfile(updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cycle settings updated!")));
        Navigator.pop(context);
      }
    }
  }
}
