import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/water_tracker_viewmodel.dart';
import '../app_colors.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? "demo_user";
    Future.microtask(() {
      context.read<WaterTrackerViewModel>().loadToday(userId);
    });
  }

  void _showMotivationIfAny(WaterTrackerViewModel vm) {
    if (vm.motivationMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.motivationMessage!), backgroundColor: AppColors.pink),
        );
        vm.clearMotivationMessage();
      });
    }
  }

  void _showCustomAmountSheet(WaterTrackerViewModel vm) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter amount (ml)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "e.g. 350", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, minimumSize: const Size.fromHeight(46)),
                onPressed: () {
                  final ml = double.tryParse(controller.text);
                  if (ml != null) {
                    vm.addIntake(ml / 1000);
                    _showMotivationIfAny(vm);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGoalPicker(WaterTrackerViewModel vm) {
    double tempGoal = vm.goal;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Set your daily goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text("${tempGoal.toStringAsFixed(1)} L", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.pink)),
                  Slider(
                    value: tempGoal,
                    min: 0.5,
                    max: 6.0,
                    divisions: 55,
                    activeColor: AppColors.pink,
                    label: "${tempGoal.toStringAsFixed(1)} L",
                    onChanged: (v) => setSheetState(() => tempGoal = v),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, minimumSize: const Size.fromHeight(46)),
                    onPressed: () {
                      vm.setGoal(tempGoal);
                      Navigator.pop(context);
                    },
                    child: const Text("Save goal", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReminderPicker(WaterTrackerViewModel vm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.reminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      vm.setReminderTime(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reminder set for ${picked.format(context)}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WaterTrackerViewModel>();
    _showMotivationIfAny(vm);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: AppColors.pink,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm),
            tooltip: "Set reminder",
            onPressed: () => _showReminderPicker(vm),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: vm.progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${vm.percent.toStringAsFixed(0)}% of ${vm.goal.toStringAsFixed(1)}L",
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.lightPink,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardPink,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderPink),
              ),
              child: Column(
                children: [
                  Text("${vm.intake.toStringAsFixed(2)} L", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.pink)),
                  const SizedBox(height: 4),
                  Text("of ${vm.goal.toStringAsFixed(1)} L goal", style: TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    vm.remaining == 0 ? "Goal reached! 🎉" : "${vm.remaining.toStringAsFixed(2)} L left to go",
                    style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _showGoalPicker(vm),
                    child: const Text("Change goal"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text("Quick add", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.pink, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [100, 250, 500].map((ml) {
                return Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
                      onPressed: () => vm.addIntake(ml / 1000),
                      child: Text("+$ml", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => vm.subtractIntake(0.1),
                    icon: const Icon(Icons.remove),
                    label: const Text("-100 ml"),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.pink),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCustomAmountSheet(vm),
                    icon: const Icon(Icons.edit),
                    label: const Text("Custom"),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.pink),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (vm.reminderTime != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Icon(Icons.alarm, color: AppColors.purple),
                    const SizedBox(width: 10),
                    Text("Reminder set for ${vm.reminderTime!.format(context)}"),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                await vm.saveToday(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.errorMessage ?? "Saved!"),
                      backgroundColor: vm.errorMessage != null ? Colors.red : null,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, minimumSize: const Size.fromHeight(48)),
              child: const Text("Save today's intake", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}