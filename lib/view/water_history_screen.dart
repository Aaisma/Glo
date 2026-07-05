import 'package:flutter/material.dart';
import '../repo/water_history_repo_impl.dart';

class WaterHistoryScreen extends StatefulWidget {
  final String userId;
  const WaterHistoryScreen({super.key, required this.userId});

  @override
  State<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen> {
  final repo = WaterHistoryRepoImpl();
  List history = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final data = await repo.getHistory(widget.userId);
    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Water History")),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];

          return ListTile(
            title: Text("${item.date}"),
            subtitle: Text(
              "Intake: ${item.intake}L | Goal: ${item.goal}L",
            ),
          );
        },
      ),
    );
  }
}