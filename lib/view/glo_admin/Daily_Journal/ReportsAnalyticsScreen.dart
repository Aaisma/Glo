import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/admin_journal_viewmodel.dart';
import '../../../model/journal_model.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminJournalViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      body: SafeArea(
        child: StreamBuilder<List<JournalModel>>(
          stream: viewModel.getAllJournals(),
          builder: (context, snapshot) {
            int totalJournals = 0;
            int journalsToday = 0;
            Map<String, int> moodCounts = {};

            if (snapshot.hasData) {
              totalJournals = snapshot.data!.length;
              final now = DateTime.now();
              for (var j in snapshot.data!) {
                if (DateUtils.isSameDay(j.createdAt, now)) {
                  journalsToday++;
                }
                moodCounts[j.mood] = (moodCounts[j.mood] ?? 0) + 1;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  _buildOverviewGrid(totalJournals, journalsToday),
                  const SizedBox(height: 20),
                  _buildSection(
                    "Journal Activity (Summary)", 
                    height: 200, 
                    child: Center(
                      child: Text(
                        "Total Recorded: $totalJournals",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    )
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    "Mood Distribution", 
                    height: 250, 
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: moodCounts.entries.map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )).toList(),
                      ),
                    )
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Download Detailed CSV", style: TextStyle(color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.download, color: Colors.white)
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return const Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: null, // This screen is part of a PageView usually
        ),
        Spacer(),
        Text("Reports & Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Spacer(),
        Icon(Icons.calendar_today),
      ],
    );
  }

  Widget _buildOverviewGrid(int total, int today) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        _StatBox(title: "New Users", val: "Real-time", trend: "Live"),
        _StatBox(title: "Journals Created", val: total.toString(), trend: "+$today today"),
        _StatBox(title: "Active Users", val: "Check Repo", trend: "0.0%"),
        _StatBox(title: "Reported Items", val: "0", trend: "None"),
      ],
    );
  }

  Widget _buildSection(String title, {required double height, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: child,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title, val, trend;
  const _StatBox({required this.title, required this.val, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bar_chart, size: 20, color: Colors.pinkAccent),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(trend, style: TextStyle(fontSize: 10, color: trend.contains('+') ? Colors.green : Colors.red)),
        ],
      ),
    );
  }
}
