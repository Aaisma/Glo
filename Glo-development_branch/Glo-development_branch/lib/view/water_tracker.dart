import 'package:flutter/material.dart';
import '../viewmodel/water_tracker_viewmodel.dart';
import '../repo/water_tracker_repo_impl.dart';
import 'water_history_screen.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  late WaterTrackerViewModel vm;
  final String userId = "demo_user";

  @override
  void initState() {
    super.initState();
    vm = WaterTrackerViewModel(WaterTrackerRepoImpl());
    vm.load(userId).then((_) => setState(() {}));
  }

  void addWater(double amount) async {
    await vm.addWater(amount, userId);
    setState(() {});
  }

  void setGoalDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Daily Goal"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter goal in liters"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double? newGoal = double.tryParse(controller.text);
              if (newGoal != null && newGoal > 0) {
                await vm.setGoal(newGoal, userId);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void setReminderDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Reminder Interval"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter interval in hours"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                vm.reminderInterval = controller.text; // simple field update
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WaterHistoryScreen(userId: userId)),
    );
  }

  void openEditNote() {
    TextEditingController controller = TextEditingController(text: vm.noteText);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Note"),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: "Write your note..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                vm.noteText = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (vm.goal == 0) ? 0 : (vm.currentIntake / vm.goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Tracker"),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: openHistory),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 💧 Intake Dashboard
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("Current Intake", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 12),
                    Text("${vm.currentIntake.toStringAsFixed(1)} L", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Goal: ${vm.goal.toStringAsFixed(1)} L", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300], color: Colors.lightBlueAccent, minHeight: 8),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: () => addWater(0.1), child: const Text("+100ml")),
                        ElevatedButton(onPressed: () => addWater(0.25), child: const Text("+250ml")),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: setGoalDialog, child: const Text("Set Goal")),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(onPressed: openHistory, icon: const Icon(Icons.history), label: const Text("View History")),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ⏰ Reminder Card
            Card(
              color: Colors.lightBlue[50],
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Reminder", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Interval: ${vm.reminderInterval.isEmpty ? "Not set" : "${vm.reminderInterval} hours"}", style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: setReminderDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text("Set Reminder"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 🌟 Motivation Card
            Card(
              color: Colors.yellow[50],
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Motivation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 12),
                    Text("\"Stay hydrated, stay happy! 💧🌞\"", textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Believe in Yourself ❤️", style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📝 Notes Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Today's Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 12),
                    Text(vm.noteText.isEmpty ? "No notes yet. Tap edit to add one." : vm.noteText, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: openEditNote, child: const Text("Edit Note")),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
