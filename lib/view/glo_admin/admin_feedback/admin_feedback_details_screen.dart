import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';

class AdminFeedbackDetailsScreen extends StatefulWidget {
  final FeedbackModel feedback;
  const AdminFeedbackDetailsScreen({super.key, required this.feedback});

  @override
  State<AdminFeedbackDetailsScreen> createState() => _AdminFeedbackDetailsScreenState();
}

class _AdminFeedbackDetailsScreenState extends State<AdminFeedbackDetailsScreen> {
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.feedback.status;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<AdminFeedbackViewModel>();

    return Scaffold(
      backgroundColor: gloBabyPinkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: gloDarkText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Feedback Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: gloPrimaryPink.withAlpha(30),
                      child: Text(widget.feedback.category.isNotEmpty ? widget.feedback.category[0] : "G", style: TextStyle(color: gloPrimaryPink, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.feedback.category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gloDarkText)),
                          Text(widget.feedback.type, style: TextStyle(color: gloDarkText.withAlpha(140), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow("Category", widget.feedback.category),
                _buildInfoRow("Type", widget.feedback.type),
                _buildInfoRow("Rating Index", "${widget.feedback.ratingIndex}"),
                const Divider(height: 32),
                Text("User Message", style: TextStyle(fontWeight: FontWeight.bold, color: gloDarkText)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: gloBabyPinkBg.withAlpha(120), borderRadius: BorderRadius.circular(16)),
                  child: Text(widget.feedback.message, style: TextStyle(color: gloDarkText, fontSize: 14, height: 1.4)),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Update Status",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ["New", "In Review", "Done"]
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStatus = val;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: gloPrimaryPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
                    onPressed: () async {
                      if (_selectedStatus != null && widget.feedback.id != null) {
                        await viewModel.updateStatus(widget.feedback.id!, _selectedStatus!);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: gloDarkText.withAlpha(140), fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: gloDarkText, fontSize: 13)),
        ],
      ),
    );
  }
}