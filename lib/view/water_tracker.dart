import 'package:flutter/material.dart';
import '../viewmodel/water_tracker_viewmodel.dart';
import '../repo/water_tracker_repo_impl.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  late WaterTrackerViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = WaterTrackerViewModel();
  }

  void addWater(double amount) {
    setState(() {
      viewModel.addWater(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              
            },
          ),
        ],
      ),
    );
  }
}