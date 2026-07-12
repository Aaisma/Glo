import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/model/admin_feedback_model.dart';

class FeedbackStatusKanbanScreen extends StatelessWidget {
  const FeedbackStatusKanbanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          title: const Text('Admin Pipeline Board', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF2D75),
            labelColor: Color(0xFFFF2D75),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'New'),
              Tab(text: 'In Review'),
              Tab(text: 'Done'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildKanbanList(viewModel.feedbacks.where((e) => e.status == 'New').toList()),
            _buildKanbanList(viewModel.feedbacks.where((e) => e.status == 'In Review').toList()),
            _buildKanbanList(viewModel.feedbacks.where((e) => e.status == 'Done').toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanList(List<AdminFeedbackModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No active tickets in this phase.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final AdminFeedbackModel entry = items[idx];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(entry.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.message, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                entry.category,
                style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}