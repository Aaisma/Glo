import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/ReviewFeedbackScreen.dart';

class FeedbackDetailsScreen extends StatelessWidget {
  const FeedbackDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();
    final item = viewModel.selectedItem;

    if (item == null) return const Scaffold(body: Center(child: Text('No selection.')));

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(item.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(item.userEmail, style: const TextStyle(color: Colors.grey)),
          const Divider(height: 32),
          Text('Category: ${item.category}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('Type: ${item.type}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text(item.message, style: const TextStyle(height: 1.4)),
          ),
          const SizedBox(height: 20),
          Text('Device: ${item.device}'),
          Text('App Version: ${item.appVersion}'),
          Text('Status Pipeline: ${item.status}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF2D75))),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D75),
              foregroundColor: Colors.white,
              // FIXED: Replaced minVerticalPadding with modern padding property
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReviewFeedbackScreen()));
            },
            child: const Text('Proceed to Review Form'),
          )
        ],
      ),
    );
  }
}