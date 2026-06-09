import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import 'tracker_components/symptom_card.dart';

class LogSymptomsPage extends StatefulWidget {
  final bool isPeriod;

  const LogSymptomsPage({super.key, required this.isPeriod});

  @override
  State<LogSymptomsPage> createState() => _LogSymptomsPageState();
}

class _LogSymptomsPageState extends State<LogSymptomsPage> {
  late Map<String, bool> _localSymptoms;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    String noteText = "";
    if (widget.isPeriod) {
      final vm = context.read<PeriodViewModel>();
      _localSymptoms = Map.from(vm.logForSelectedDate?.symptoms ?? {});
      noteText = vm.logForSelectedDate?.note ?? "";
    } else {
      final vm = context.read<OvulationViewModel>();
      _localSymptoms = Map.from(vm.logForSelectedDate?.symptoms ?? {});
      noteText = vm.logForSelectedDate?.note ?? "";
    }
    _noteController = TextEditingController(text: noteText);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleOptionSelected(String option, List<SymptomOption> categoryOptions, bool isSingleChoice) {
    setState(() {
      if (isSingleChoice) {
        // Clear others in the category
        for (var catOption in categoryOptions) {
          _localSymptoms[catOption.label] = false;
        }
        _localSymptoms[option] = true;
      } else {
        _localSymptoms[option] = !(_localSymptoms[option] ?? false);
      }
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
      if (_noteController.text != (vm.logForSelectedDate?.note ?? "")) {
        vm.saveNote(_noteController.text);
      }
    } else {
      final vm = context.read<OvulationViewModel>();
      for (var entry in _localSymptoms.entries) {
        if (entry.value != (vm.logForSelectedDate?.symptoms[entry.key] ?? false)) {
          vm.toggleSymptom(entry.key);
        }
      }
      if (_noteController.text != (vm.logForSelectedDate?.note ?? "")) {
        vm.saveNote(_noteController.text);
      }
    }
    Navigator.pop(context);
  }

  Set<String> _getSelectedOptions() {
    return _localSymptoms.entries.where((e) => e.value).map((e) => e.key).toSet();
  }

  final List<SymptomOption> sexualActivityOptions = const [
    SymptomOption("No Sex", Icons.block),
    SymptomOption("Protected", Icons.health_and_safety),
    SymptomOption("Unprotected", Icons.warning_amber),
    SymptomOption("Oral Sex", Icons.face),
    SymptomOption("Anal Sex", Icons.lens_blur),
    SymptomOption("Masturbation", Icons.back_hand),
    SymptomOption("Sensual Touch", Icons.touch_app),
    SymptomOption("Sex Toy", Icons.vibration),
    SymptomOption("Orgasm", Icons.star),
  ];

  final List<SymptomOption> sexDriveOptions = const [
    SymptomOption("High", Icons.keyboard_double_arrow_up),
    SymptomOption("Neutral", Icons.remove),
    SymptomOption("Low", Icons.keyboard_double_arrow_down),
  ];

  final List<SymptomOption> periodSymptomsOptions = const [
    SymptomOption("No Symptoms", Icons.sentiment_satisfied),
    SymptomOption("Cramps", Icons.sick),
    SymptomOption("Tender Breast", Icons.favorite),
    SymptomOption("Headache", Icons.face_retouching_off),
    SymptomOption("Acne", Icons.face),
    SymptomOption("Backache", Icons.airline_seat_flat),
    SymptomOption("Fatigue", Icons.battery_alert),
    SymptomOption("Cravings", Icons.restaurant),
    SymptomOption("Insomnia", Icons.bedtime),
    SymptomOption("Constipation", Icons.bathroom),
    SymptomOption("Lower Back", Icons.accessibility_new),
    SymptomOption("Abdominal", Icons.healing),
    SymptomOption("Pelvic Pain", Icons.personal_injury),
    SymptomOption("Itching", Icons.waves),
    SymptomOption("Dryness", Icons.water_drop),
    SymptomOption("Hot Flashes", Icons.local_fire_department),
    SymptomOption("Sweats", Icons.water),
    SymptomOption("Bloating", Icons.air),
    SymptomOption("Mood Swings", Icons.compare_arrows),
    SymptomOption("Nausea", Icons.sick),
  ];

  final List<SymptomOption> vaginalDischargeOptions = const [
    SymptomOption("None", Icons.not_interested),
    SymptomOption("Creamy", Icons.opacity),
    SymptomOption("Watery", Icons.water_drop),
    SymptomOption("Sticky", Icons.hive),
    SymptomOption("Egg white", Icons.egg),
    SymptomOption("Spotting", Icons.fiber_manual_record),
    SymptomOption("Unusual", Icons.warning),
    SymptomOption("Clumpy", Icons.cloud),
    SymptomOption("Grey", Icons.lens),
  ];

  final List<SymptomOption> ovulationTestOptions = const [
    SymptomOption("Not Taken", Icons.cancel_outlined),
    SymptomOption("Negative", Icons.remove_circle_outline),
    SymptomOption("Positive", Icons.add_circle_outline),
  ];

  final List<SymptomOption> pregnancyTestOptions = const [
    SymptomOption("Not Taken", Icons.cancel_outlined),
    SymptomOption("Negative", Icons.remove_circle_outline),
    SymptomOption("Positive", Icons.add_circle_outline),
    SymptomOption("Faint line", Icons.linear_scale),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = widget.isPeriod ? periodTheme : ovulationTheme;
    final selectedOptions = _getSelectedOptions();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Minimalist pastel Neutral Grey background
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
                SymptomCard(
                  title: "Sexual Activity",
                  options: sexualActivityOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: false,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, sexualActivityOptions, false),
                ),
                SymptomCard(
                  title: "Sex Drive",
                  options: sexDriveOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: true,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, sexDriveOptions, true),
                ),
                SymptomCard(
                  title: "Symptoms",
                  options: periodSymptomsOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: false,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, periodSymptomsOptions, false),
                ),
                SymptomCard(
                  title: "Vaginal Discharge",
                  options: vaginalDischargeOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: true,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, vaginalDischargeOptions, true),
                ),
                SymptomCard(
                  title: "Ovulation Test",
                  options: ovulationTestOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: true,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, ovulationTestOptions, true),
                ),
                SymptomCard(
                  title: "Pregnancy Test",
                  options: pregnancyTestOptions,
                  selectedOptions: selectedOptions,
                  isSingleChoice: true,
                  theme: theme,
                  onOptionSelected: (opt) => _handleOptionSelected(opt, pregnancyTestOptions, true),
                ),
                
                // Notes Section Component built inline
                _buildNotesCard(theme),
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

  Widget _buildNotesCard(ThemeColors theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Notes",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Add additional details...",
                hintStyle: TextStyle(color: Colors.black38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
