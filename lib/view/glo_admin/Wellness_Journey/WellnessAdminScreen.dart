import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_wellness_viewmodel.dart';
import 'package:glo/model/user_model.dart';
import 'package:glo/model/user_model_mood.dart';
import 'UserWellnessScreen.dart';
import 'MoodAnalyticsScreen.dart';
import 'WellnessCalendarScreen.dart';
import 'JournalReviewScreen.dart';

class WellnessAdminScreen extends StatefulWidget {
  const WellnessAdminScreen({super.key});

  @override
  State<WellnessAdminScreen> createState() => _WellnessAdminScreenState();
}

class _WellnessAdminScreenState extends State<WellnessAdminScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminWellnessViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                StreamBuilder(
                  stream: viewModel.getAllUsers(),
                  builder: (context, AsyncSnapshot<List<UserModel>> userSnapshot) {
                    return StreamBuilder(
                      stream: viewModel.getAllMoodLogs(),
                      builder: (context, AsyncSnapshot<List<UserModelMood>> moodSnapshot) {
                        int totalUsers = userSnapshot.data?.length ?? 0;
                        int totalMoodLogs = moodSnapshot.data?.length ?? 0;
                        
                        // Simple logic for high risk: e.g., users with many 'Sad' or 'Angry' logs
                        int highRiskCount = 0;
                        if (moodSnapshot.hasData) {
                          final sadOrAngry = moodSnapshot.data!.where((m) => m.moodType == 'Sad' || m.moodType == 'Angry').toList();
                          // This is a placeholder logic
                          highRiskCount = sadOrAngry.length; 
                        }

                        return _buildOverviewGrid(totalUsers, totalMoodLogs, highRiskCount);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildQuickAccessSection(context),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Column(
          children: [
            Text("Wellness Journey", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Admin Overview", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Icon(Icons.notifications_none),
      ],
    );
  }

  Widget _buildOverviewGrid(int totalUsers, int moodLogs, int highRisk) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.8,
      children: [
        _buildStatCard("Total Users", totalUsers.toString(), "+Live"),
        _buildStatCard("Mood Logs", moodLogs.toString(), "+Live"),
        _buildStatCard("Journals", "Real-time", "Link"),
        _buildStatCard("Streaks", "Coming", "Soon"),
        _buildStatCard("Wellness", "84%", "+5%"),
        _buildStatCard("High Risk", highRisk.toString(), "Alert"),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 2),
          Text(change, style: TextStyle(fontSize: 8, color: change.contains('+') ? Colors.green : Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Access", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildQuickAccessItem(context, "User Wellness", const UserWellnessScreen()),
        _buildQuickAccessItem(context, "Insights Dashboard (Analytics)", const MoodAnalyticsScreen()),
        _buildQuickAccessItem(context, "Wellness Calendar", const WellnessCalendarScreen()),
        _buildQuickAccessItem(context, "Journal Review", const JournalReviewScreen()),
      ],
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, String title, Widget targetScreen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Icon(Icons.chevron_right, size: 20, color: Colors.pinkAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text("Community wellness is growing 🌸", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
      ),
    );
  }
}
