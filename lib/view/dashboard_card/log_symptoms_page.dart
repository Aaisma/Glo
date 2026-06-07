import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';

class LogSymptomsPage extends StatefulWidget {
  final bool isPeriod;

  const LogSymptomsPage({super.key, required this.isPeriod});

  @override
  State<LogSymptomsPage> createState() => _LogSymptomsPageState();
}

class _LogSymptomsPageState extends State<LogSymptomsPage> {
  late Map<String, bool> _localSymptoms;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the corresponding ViewModel
    if (widget.isPeriod) {
      final vm = context.read<PeriodViewModel>();
      _localSymptoms = Map.from(vm.logForSelectedDate?.symptoms ?? {});
    } else {
      final vm = context.read<OvulationViewModel>();
      _localSymptoms = Map.from(vm.logForSelectedDate?.symptoms ?? {});
    }
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      _localSymptoms[symptom] = !(_localSymptoms[symptom] ?? false);
    });
  }

  void _saveSymptoms() {
    if (widget.isPeriod) {
      final vm = context.read<PeriodViewModel>();
      for (var entry in _localSymptoms.entries) {
        if (entry.value != (vm.logForSelectedDate?.symptoms[entry.key] ?? false)) {
          vm.toggleSymptom(entry.key);
        }
      }
    } else {
      final vm = context.read<OvulationViewModel>();
      for (var entry in _localSymptoms.entries) {
        if (entry.value != (vm.logForSelectedDate?.symptoms[entry.key] ?? false)) {
          vm.toggleSymptom(entry.key);
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.isPeriod ? periodTheme : ovulationTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.headerText),
        title: Text(
          "Log Symptoms",
          style: TextStyle(color: theme.headerText, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection("Period Symptoms", [
                  "Flow", "Cramps", "Bloating", "Fatigue", "Acne", "Tender Breasts"
                ], theme),
                const SizedBox(height: 16),
                _buildSection("Ovulation Symptoms", [
                  "Cervical Mucus", "Ovulation Pain", "Libido", "Breast Tenderness"
                ], theme),
                const SizedBox(height: 16),
                _buildSection("Sex & Intimacy", [
                  "Unprotected", "Protected", "High Drive", "Low Drive"
                ], theme),
                const SizedBox(height: 16),
                _buildSection("Pregnancy Testing", [
                  "Positive", "Negative", "Faint Line"
                ], theme),
                const SizedBox(height: 16),
                _buildSection("General Physical", [
                  "Headache", "Backache", "Nausea", "Dizziness"
                ], theme),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonBg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Save Symptoms", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> symptoms, ThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms.map((symptom) {
            final isActive = _localSymptoms[symptom] == true;
            return GestureDetector(
              onTap: () => _toggleSymptom(symptom),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? theme.headerText : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? theme.headerText : theme.border),
                ),
                child: Text(
                  symptom,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF666666),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
