import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/model/feedback_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/admin_feedback_details_screen.dart';

class AdminFeedbackDashboardScreen extends StatefulWidget {
  const AdminFeedbackDashboardScreen({super.key});

  @override
  State<AdminFeedbackDashboardScreen> createState() => _AdminFeedbackDashboardScreenState();
}

class _AdminFeedbackDashboardScreenState extends State<AdminFeedbackDashboardScreen> {
  final Color gloPrimaryPink = const Color(0xFFFF4081);
  final Color gloDarkText = const Color(0xFF2C1330);
  final Color gloBabyPinkBg = const Color(0xFFFFF0F3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFeedbackViewModel>().fetchAllFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();

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
        title: Text("Feedback Portal", style: TextStyle(color: gloDarkText, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: () => viewModel.fetchAllFeedbacks(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Overview 📊", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gloDarkText)),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard(viewModel.feedbacks.length.toString(), "Total Feedback", Icons.chat_bubble_outline, Colors.pink),
                    _buildStatCard("4.2", "Avg Rating", Icons.star_border, Colors.amber),
                    _buildStatCard(viewModel.feedbacks.where((e) => e.status == 'Done').length.toString(), "Resolved", Icons.check_circle_outline, Colors.green),
                    _buildStatCard(viewModel.feedbacks.where((e) => e.status == 'New').length.toString(), "Pending", Icons.error_outline, Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                Text("User Submissions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gloDarkText)),
                const SizedBox(height: 12),
                viewModel.feedbacks.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: Text("No feedback reports found.")),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = viewModel.feedbacks[index];
                    return _buildMobileFeedbackItem(context, feedback);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: gloDarkText)),
          Text(title, style: TextStyle(color: gloDarkText.withAlpha(150), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMobileFeedbackItem(BuildContext context, FeedbackModel feedback) {
    Color statusColor = feedback.status == 'Done' ? Colors.green : (feedback.status == 'In Review' ? Colors.orange : Colors.red);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminFeedbackDetailsScreen(feedback: feedback)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("User Report", style: TextStyle(fontWeight: FontWeight.bold, color: gloDarkText, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                  child: Text(feedback.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("${feedback.category} • ${feedback.type}", style: TextStyle(color: gloPrimaryPink, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(feedback.message, style: TextStyle(color: gloDarkText.withAlpha(180), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Score Index: ${feedback.ratingIndex}", style: TextStyle(fontSize: 12, color: Colors.amber.shade700, fontWeight: FontWeight.bold)),
                Text("View Details →", style: TextStyle(color: gloPrimaryPink, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}