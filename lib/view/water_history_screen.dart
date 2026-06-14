import 'package:flutter/material.dart';
import '../viewmodel/water_history_viewmodel.dart';
import '../repo/water_history_repo_impl.dart';
import '../model/water_history_model.dart';

class WaterHistoryScreen extends StatefulWidget {
  const WaterHistoryScreen({super.key});

  @override
  State<WaterHistoryScreen> createState() => _WaterHistoryScreenState();
}

class _WaterHistoryScreenState extends State<WaterHistoryScreen> {
  late WaterHistoryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = WaterHistoryViewModel(WaterHistoryRepoImpl());

    viewModel.loadHistory().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water History"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: viewModel.history.length,
        itemBuilder: (context, index) {
          final item = viewModel.history[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("Date: ${item.date}"),
              subtitle: Text(
                "Intake: ${item.intake} L\nGoal: ${item.goal} L\nCompletion: ${item.percent.toStringAsFixed(1)}%",
              ),
              trailing: Icon(
                item.percent >= 100
                    ? Icons.check_circle
                    : Icons.water_drop,
                color: item.percent >= 100 ? Colors.green : Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }
}