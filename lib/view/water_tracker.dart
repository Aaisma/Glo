import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodel/water_tracker_viewmodel.dart';

import 'water_history_screen.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  final Set<int> _celebratedThresholds = {};
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final vm = context.read<WaterTrackerViewModel>();
      if (vm.userId != null) {
        vm.loadToday(vm.userId!);
      }
    });
  }

  void _checkMotivation(WaterTrackerViewModel vm) {
    if (vm.goal <= 0) return;
    final pct = (vm.intake / vm.goal) * 100;

    final thresholds = {
      25: "Great start! You're 25% hydrated 💧",
      50: "Halfway there! Keep it up 🌊",
      75: "75% done! Almost at your goal 💪",
      100: "🎉 Goal reached! Amazing hydration today!",
    };

    for (final entry in thresholds.entries) {
      if (pct >= entry.key && !_celebratedThresholds.contains(entry.key)) {
        _celebratedThresholds.add(entry.key);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(entry.value),
            backgroundColor: Colors.blueAccent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // nudge if below 50% after first log
    if (pct < 50 && vm.intake > 0 && !_celebratedThresholds.contains(-1)) {
      _celebratedThresholds.add(-1);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Keep Going! 💧"),
            content: const Text(
                "You haven't reached your goal yet. Would you like to adjust or calculate your daily goal?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Keep Current Goal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showGoalPicker(context.read<WaterTrackerViewModel>());
                },
                child: const Text("Adjust Goal"),
              ),
            ],
          ),
        );
      });
    }
  }

  void _showGoalPicker(WaterTrackerViewModel vm) {
    double tempGoal = vm.goal;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Set Daily Goal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${tempGoal.toStringAsFixed(1)} L",
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              Slider(
                value: tempGoal,
                min: 0.5,
                max: 6.0,
                divisions: 55,
                activeColor: Colors.blueAccent,
                label: "${tempGoal.toStringAsFixed(1)} L",
                onChanged: (v) => setDialogState(() => tempGoal = v),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showGoalCalculator(vm);
                },
                icon: const Icon(Icons.calculate, size: 18),
                label: const Text("Calculate Ideal Goal"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                vm.setGoal(tempGoal);
                _celebratedThresholds.clear();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      }),
    );
  }

  void _showGoalCalculator(WaterTrackerViewModel vm) {
    final weightController = TextEditingController(text: "70");
    String activityLevel = "Medium";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Ideal Goal Calculator"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Your Weight (kg)", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "e.g. 70",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Daily Activity Level", style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: activityLevel,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: ["Low (Sedentary)", "Medium (Active)", "High (Athletic)"]
                    .map((val) => DropdownMenuItem(
                  value: val.split(" ").first,
                  child: Text(val),
                ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => activityLevel = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              onPressed: () {
                final weight = double.tryParse(weightController.text) ?? 70.0;
                // Formula: Weight (kg) * 0.033 + activity adjustment
                double calculated = weight * 0.033;
                if (activityLevel == "Medium") {
                  calculated += 0.5;
                } else if (activityLevel == "High") {
                  calculated += 1.0;
                }

                // Clamp goal values to user friendly range
                calculated = calculated.clamp(1.0, 6.0);

                vm.setGoal(calculated);
                _celebratedThresholds.clear();
                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Calculated water goal set to ${calculated.toStringAsFixed(1)}L! 💧"),
                    backgroundColor: Colors.blueAccent,
                  ),
                );
              },
              child: const Text("Set Goal"),
            ),
          ],
        );
      }),
    );
  }

  void _showCustomAmountSheet(WaterTrackerViewModel vm) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Custom Water Amount (ml)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "e.g. 350",
                  border: OutlineInputBorder(),
                  suffixText: "ml",
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final ml = double.tryParse(controller.text);
                        if (ml != null && ml > 0) {
                          vm.subtractIntake(ml / 1000);
                          setState(() {});
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("− Subtract"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final ml = double.tryParse(controller.text);
                        if (ml != null && ml > 0) {
                          vm.addIntake(ml / 1000);
                          _checkMotivation(vm);
                          setState(() {});
                        }
                        Navigator.pop(context);
                      },
                      child: const Text("+ Add",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReminderPicker(WaterTrackerViewModel vm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.reminderTime ?? TimeOfDay.now(),
      helpText: "Pick reminder time",
    );
    if (picked != null) {
      vm.setReminderTime(picked);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reminder set for ${picked.format(context)} 💧"),
          ),
        );
      }
    }
  }

  void _showEditNoteDialog(WaterTrackerViewModel vm) {
    _noteController.text = vm.note;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Today's Notes"),
        content: TextField(
          controller: _noteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Write how you feel or logs here...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              vm.updateNote(_noteController.text);
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Helper to map the last 7 calendar days to history list entries
  List<BarChartGroupData> _buildBarGroups(WaterTrackerViewModel vm) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = date.toIso8601String().split("T")[0];

      double intakeVal = 0.0;
      double goalVal = vm.goal;
      for (final entry in vm.history) {
        if (entry.date == dateStr) {
          intakeVal = entry.intake;
          goalVal = entry.goal;
          break;
        }
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: intakeVal,
            color: intakeVal >= goalVal ? Colors.blue : Colors.lightBlueAccent,
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: goalVal > 0 ? goalVal : 2.5,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
      );
    });
  }

  String _getWeekdayLabel(int index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    switch (date.weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WaterTrackerViewModel>();
    final double progress =
    vm.goal == 0 ? 0 : (vm.intake / vm.goal).clamp(0.0, 1.0);
    final double remaining = (vm.goal - vm.intake).clamp(0.0, vm.goal);

    return Scaffold(
      backgroundColor: Colors.blue.shade50.withValues(alpha: 0.3),
      appBar: AppBar(
        title: const Text("Water Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          if (vm.streak > 0)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    "${vm.streak}d",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history_toggle_off),
            tooltip: "View History List",
            onPressed: vm.userId == null ? null : () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => WaterHistoryScreen(userId: vm.userId!)),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/feed/community_backgroung.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            // 💧 Central Hydration Wave Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.blue.shade100, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Custom wave widget
                    WaveProgressWidget(progress: progress, size: 190),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${vm.intake.toStringAsFixed(2)} L logged",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Goal: ${vm.goal.toStringAsFixed(1)} L",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              remaining <= 0 ? "Goal met! 🎉" : "${remaining.toStringAsFixed(2)} L left",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: remaining <= 0 ? Colors.green : Colors.blue.shade800,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showGoalPicker(vm),
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text("Adjust goal"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⚡ Quick Add Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.blue.shade100, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quick Log",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        if (vm.lastAddedAmount > 0)
                          TextButton.icon(
                            onPressed: () {
                              vm.undoLastIntake();
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Undid last log! ↩️"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.undo, size: 16),
                            label: const Text("Undo", style: TextStyle(fontSize: 13)),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Glass 1: Cup (150ml)
                        _buildQuickAddCup(
                          context: context,
                          vm: vm,
                          icon: Icons.local_cafe,
                          label: "150ml",
                          value: 0.15,
                        ),
                        // Glass 2: Medium (250ml)
                        _buildQuickAddCup(
                          context: context,
                          vm: vm,
                          icon: Icons.local_drink,
                          label: "250ml",
                          value: 0.25,
                        ),
                        // Glass 3: Bottle (500ml)
                        _buildQuickAddCup(
                          context: context,
                          vm: vm,
                          icon: Icons.water_drop,
                          label: "500ml",
                          value: 0.50,
                        ),
                        // Glass 4: Custom
                        _buildQuickAddCup(
                          context: context,
                          vm: vm,
                          icon: Icons.tune,
                          label: "Custom",
                          isCustom: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⏰ Reminder & 📝 Notes Cards (Side by Side)
            Row(
              children: [
                // Reminder Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showReminderPicker(vm),
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Reminder",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Icon(Icons.alarm, color: Colors.blue.shade700, size: 20),
                            ],
                          ),
                          Text(
                            vm.reminderTime == null
                                ? "Not set"
                                : vm.reminderTime!.format(context),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: vm.reminderTime == null ? Colors.grey : Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Notes Card
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showEditNoteDialog(vm),
                    child: Container(
                      height: 110,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Today's Notes",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Icon(Icons.edit_note, color: Colors.blue.shade700, size: 22),
                            ],
                          ),
                          Text(
                            vm.note.isEmpty ? "Tap to add note..." : vm.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: vm.note.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📊 Weekly Analytics Chart
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.blue.shade100, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Weekly Analytics",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: math.max(4.0, vm.goal + 0.5),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => Colors.blueAccent.withValues(alpha: 0.9),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  "${rod.toY.toStringAsFixed(1)} L",
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= 7) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _getWeekdayLabel(i),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: _buildBarGroups(vm),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 💾 Save today's intake button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size.fromHeight(52),
                elevation: 0,
              ),
              onPressed: (vm.isLoading || vm.userId == null)
                  ? null
                  : () async {
                await vm.saveToday(vm.userId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.errorMessage ?? "Hydration progress saved successfully! 💧"),
                      backgroundColor: vm.errorMessage != null ? Colors.red : Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text(
                "Save Today's Progress",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Motivation Tip
            const Center(
              child: Text(
                "Believe in yourself • Stay hydrated ❤️",
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildQuickAddCup({
    required BuildContext context,
    required WaterTrackerViewModel vm,
    required IconData icon,
    required String label,
    double? value,
    bool isCustom = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isCustom) {
          _showCustomAmountSheet(vm);
        } else if (value != null) {
          vm.addIntake(value);
          _checkMotivation(vm);
          setState(() {});
        }
      },
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue.shade700, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🌊 CUSTOM WAVE ANIMATION PROGRESS WIDGET
class WaveProgressWidget extends StatefulWidget {
  final double progress;
  final double size;

  const WaveProgressWidget({
    super.key,
    required this.progress,
    this.size = 200,
  });

  @override
  State<WaveProgressWidget> createState() => _WaveProgressWidgetState();
}

class _WaveProgressWidgetState extends State<WaveProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade50.withValues(alpha: 0.6),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade500.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
            border: Border.all(color: Colors.blue.shade200, width: 4),
          ),
          child: ClipOval(
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: WavePainter(
                    animationValue: _controller.value,
                    progress: widget.progress,
                    waveColor: Colors.blue.shade300,
                  ),
                ),
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: WavePainter(
                    animationValue: _controller.value + 0.5,
                    progress: widget.progress,
                    waveColor: Colors.blue.shade200.withValues(alpha: 0.8),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${(widget.progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          fontSize: widget.size * 0.22,
                          fontWeight: FontWeight.bold,
                          color: widget.progress > 0.52
                              ? Colors.white
                              : Colors.blue.shade800,
                          shadows: widget.progress > 0.52
                              ? [
                            const Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 4,
                            ),
                          ]
                              : null,
                        ),
                      ),
                      Text(
                        "hydrated",
                        style: TextStyle(
                          fontSize: widget.size * 0.08,
                          fontWeight: FontWeight.w500,
                          color: widget.progress > 0.52
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color waveColor;

  WavePainter({
    required this.animationValue,
    required this.progress,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = waveColor;
    final path = Path();

    // Calculate wave vertical offset based on progress
    final double yCenter = size.height * (1.0 - progress);

    final double waveWidth = size.width;
    final double waveHeight = size.height * 0.05; // Amplitude of waves

    path.moveTo(0, size.height);
    for (double x = 0; x <= waveWidth; x++) {
      // Sine wave equation: y = amplitude * sin(frequency * x + time) + vertical_offset
      final double radian = (x / waveWidth * 2 * math.pi) + (animationValue * 2 * math.pi);
      final double y = yCenter + math.sin(radian) * waveHeight;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}