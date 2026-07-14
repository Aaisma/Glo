import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/model/admin_feedback_model.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/FeedbackDetailsScreen.dart';
import 'package:intl/intl.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Admin Feedback List', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFF2D75)),
            onPressed: () => viewModel.loadAllFeedback(),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF2D75)))
          : viewModel.feedbacks.isEmpty
              ? const Center(child: Text('No feedback entries found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.feedbacks.length,
                  itemBuilder: (context, index) {
                    final AdminFeedbackModel feedbackItem = viewModel.feedbacks[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(feedbackItem.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  feedbackItem.overallScore.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              feedbackItem.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2D75).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    feedbackItem.category,
                                    style: const TextStyle(color: Color(0xFFFF2D75), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(feedbackItem.timestamp),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                        onTap: () {
                          viewModel.selectItem(feedbackItem);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FeedbackDetailsScreen()),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
