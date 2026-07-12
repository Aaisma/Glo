import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glo/viewmodel/admin_feedback_view_model.dart';
import 'FiltersSearchScreen.dart';

class AnalyticsOverviewScreen extends StatelessWidget {
  const AnalyticsOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminFeedbackViewModel>();
    
    // Calculate category distribution
    Map<String, int> categoryCounts = {};
    for (var f in viewModel.feedbacks) {
      categoryCounts[f.category] = (categoryCounts[f.category] ?? 0) + 1;
    }
    
    int total = viewModel.totalCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Feedback Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: viewModel.isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF2D75)))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(12), 
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart, size: 40, color: Color(0xFFFF2D75)),
                const SizedBox(height: 8),
                const Text('Average Community Rating', style: TextStyle(color: Colors.grey)),
                Text(
                  viewModel.averageScore.toStringAsFixed(1), 
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)
                ),
                Text('Based on $total entries', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Category Distribution Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (categoryCounts.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No data available to analyze yet.'),
            ))
          else
            ...categoryCounts.entries.map((e) {
              double percentage = total > 0 ? (e.value / total) * 100 : 0;
              return _buildBarRow(e.key, '${percentage.toStringAsFixed(1)}%', _getCategoryColor(e.key));
            }).toList(),
          
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D75), 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FiltersSearchScreen())),
            child: const Text('Open Filtering Matrix'),
          )
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'period tracker': return Colors.pink;
      case 'mood tracker': return Colors.purple;
      case 'ovulation logs': return Colors.blue;
      case 'app experience': return Colors.orange;
      case 'bug report': return Colors.red;
      default: return Colors.teal;
    }
  }

  Widget _buildBarRow(String title, String percent, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
              Text(percent, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: double.parse(percent.replaceAll('%', '')) / 100,
              backgroundColor: c.withOpacity(0.1),
              color: c,
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }
}
