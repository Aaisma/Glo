import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'package:glo/view/glo_admin/admin_feedback/DashboardScreen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch for feedback changes to update the card count
    final feedbackViewModel = context.watch<AdminFeedbackViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Color(0xFF1E1E2F)),
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E2F))),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Color(0xFF1E1E2F)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const Text('Admin 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2F))),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildGridCard('Users', 'Live', Colors.purple),
                _buildGridCard('Health Insights', 'Total', Colors.teal),
                _buildGridCard('Community', 'Forum', Colors.blue),
                _buildGridCard('Wellness', 'Moods', Colors.orange),
                _buildGridCard('Tracking', 'Logs', Colors.green),

                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2D75),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Admin Feedback', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(height: 4),
                        feedbackViewModel.isLoading 
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              '${feedbackViewModel.totalCount}', 
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Recent System Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (feedbackViewModel.feedbacks.isEmpty)
               const Center(child: Text("Waiting for community data...", style: TextStyle(color: Colors.grey, fontSize: 12)))
            else
               ...feedbackViewModel.feedbacks.take(4).map((f) => _buildActivityItem(
                 'Feedback: ${f.category}', 
                 f.userName, 
                 'Recent', 
                 Icons.rate_review, 
                 Colors.pink
               )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String label, String count, Color col) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 4),
          Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: col)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String user, String time, IconData icon, Color col) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: col.withOpacity(0.1), child: Icon(icon, color: col, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(user, style: const TextStyle(fontSize: 12)),
        trailing: Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
      ),
    );
  }
}
