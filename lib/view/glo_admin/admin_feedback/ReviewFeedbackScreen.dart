import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/AnalyticsOverviewScreen.dart';

class ReviewFeedbackScreen extends StatefulWidget {
  const ReviewFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<ReviewFeedbackScreen> createState() => _ReviewFeedbackScreenState();
}

class _ReviewFeedbackScreenState extends State<ReviewFeedbackScreen> {
  String priority = 'Medium';
  String assignedAdmin = 'Select Admin';
  late String statusUpdate;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final selectedItem = context.read<AdminFeedbackViewModel>().selectedItem;
      statusUpdate = selectedItem?.status ?? 'New';
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();
    final item = viewModel.selectedItem;

    if (item == null) {
      return const Scaffold(body: Center(child: Text('No feedback selected.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Review Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(item),
          const SizedBox(height: 24),
          const Text('Processing Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Priority Level',
            value: priority,
            items: ['Low', 'Medium', 'High'],
            onChanged: (v) => setState(() => priority = v!),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Assign Responsible Admin',
            value: assignedAdmin,
            items: ['Select Admin', 'Officer Alex', 'Manager Sarah', 'Lead Priya'],
            onChanged: (v) => setState(() => assignedAdmin = v!),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Pipeline Status',
            value: statusUpdate,
            items: ['New', 'In Review', 'Done'],
            onChanged: (v) => setState(() => statusUpdate = v!),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2D75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await viewModel.updateFeedbackStatus(item.id, statusUpdate);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Feedback status updated to $statusUpdate')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalyticsOverviewScreen()),
                      );
                    }
                  },
                  child: const Text('Finalize Review'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(item.userEmail, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 24),
          Text(item.message, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
