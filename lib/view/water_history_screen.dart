import 'package:flutter/material.dart';

class WaterHistoryScreen extends StatelessWidget {
  const WaterHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> history = [
      {"date": "Mon", "intake": 2.1},
      {"date": "Tue", "intake": 2.5},
      {"date": "Wed", "intake": 1.8},
      {"date": "Thu", "intake": 2.0},
      {"date": "Fri", "intake": 2.3},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water History"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.blue),
              title: Text(item["date"]),
              trailing: Text("${item["intake"]} L"),
            ),
          );
        },
      ),
    );
  }
}