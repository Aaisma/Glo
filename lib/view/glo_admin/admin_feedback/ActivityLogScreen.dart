import 'package:flutter/material.dart';
import 'package:glo/view/glo_admin/admin_feedback/FeedbackStatusKanbanScreen.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Activity Log')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _logTile('Feedback ticket registered', 'Sarah Johnson • May 24, 2026', Icons.add_circle, Colors.green),
          _logTile('Status mapped to In Review', 'Ananya Sharma • May 23, 2026', Icons.swap_horiz, Colors.orange),
          _logTile('Diagnostic Score updated', 'Database Engine • May 22, 2026', Icons.edit, Colors.blue),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF2D75), foregroundColor: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackStatusKanbanScreen())),
            child: const Text('View Kanban Stage Board'),
          ),
        ],
      ),
    );
  }

  Widget _logTile(String event, String stamp, IconData i, Color c) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: c.withOpacity(0.1), child: Icon(i, color: c)),
      title: Text(event, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(stamp),
    );
  }
}