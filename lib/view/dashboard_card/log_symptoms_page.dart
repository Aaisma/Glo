import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../../constants/ovulation_period_symptoms_colours.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';
import '../../viewmodel/log_symptoms_view_model.dart';
import 'tracker_components/symptom_card.dart';
import '../navigation_icon/dashboard_page.dart';

const List<SymptomOption> sexualActivityOptions = [
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

const List<SymptomOption> sexDriveOptions = [
  SymptomOption("High", Icons.keyboard_double_arrow_up),
  SymptomOption("Neutral", Icons.remove),
  SymptomOption("Low", Icons.keyboard_double_arrow_down),
];

const List<SymptomOption> periodSymptomsOptions = [
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

const List<SymptomOption> ovulationSymptomsOptions = [
  SymptomOption("No Symptoms", Icons.sentiment_satisfied),
  SymptomOption("Cervical Mucus", Icons.water_drop),
  SymptomOption("Ovulation Pain", Icons.health_and_safety),
  SymptomOption("Libido", Icons.favorite),
  SymptomOption("Breast Tenderness", Icons.face),
  SymptomOption("Bloating", Icons.air),
];

const List<SymptomOption> vaginalDischargeOptions = [
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

const List<SymptomOption> ovulationTestOptions = [
  SymptomOption("Not Taken", Icons.cancel_outlined),
  SymptomOption("Negative", Icons.remove_circle_outline),
  SymptomOption("Positive", Icons.add_circle_outline),
];

const List<SymptomOption> pregnancyTestOptions = [
  SymptomOption("Not Taken", Icons.cancel_outlined),
  SymptomOption("Negative", Icons.remove_circle_outline),
  SymptomOption("Positive", Icons.add_circle_outline),
  SymptomOption("Faint line", Icons.linear_scale),
];

class LogSymptomsPage extends StatefulWidget {
  final bool isPeriod;

  const LogSymptomsPage({super.key, required this.isPeriod});

  @override
  State<LogSymptomsPage> createState() => _LogSymptomsPageState();
}

class _LogSymptomsPageState extends State<LogSymptomsPage> {
  late LogSymptomsViewModel _viewModel;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _viewModel = LogSymptomsViewModel(
      isPeriod: widget.isPeriod,
      periodViewModel: widget.isPeriod ? context.read<PeriodViewModel>() : null,
      ovulationViewModel: !widget.isPeriod ? context.read<OvulationViewModel>() : null,
    );
    _noteController = TextEditingController(text: _viewModel.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _saveSymptoms() {
    _viewModel.saveSymptoms();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }



  @override
  Widget build(BuildContext context) {
    final englishDate = DateFormat('E, MMMM d, yyyy').format(DateTime.now());
    final nepaliDate = NepaliDateFormat('MMMM d, yyyy').format(NepaliDateTime.now());

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        final isSavedStatus = _viewModel.isSaved;

        return Scaffold(
          backgroundColor: SymptomColours.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: const BackButton(color: SymptomColours.textPrimary),
            title: Row(
              children: const [
                Text(
                  "Log Symptoms",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SymptomColours.textPrimary),
                ),
                SizedBox(width: 8),
                Icon(Icons.info_outline, size: 20, color: SymptomColours.textSecondary),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 24),
                      child: Text(
                        "Track symptoms and health observations for today.",
                        style: TextStyle(fontSize: 14, color: SymptomColours.textSecondary),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: SymptomColours.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SymptomColours.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Gregorian Date (AD):", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: SymptomColours.textPrimary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        englishDate,
                                        style: const TextStyle(fontSize: 12, color: SymptomColours.textPrimary, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: SymptomColours.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SymptomColours.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Nepali Date (BS):", style: TextStyle(fontSize: 11, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: SymptomColours.textPrimary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        nepaliDate,
                                        style: const TextStyle(fontSize: 12, color: SymptomColours.textPrimary, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle, 
                            size: 8, 
                            color: isSavedStatus ? Colors.green : SymptomColours.warning
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isSavedStatus ? "All changes saved" : "Unsaved changes",
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.w500, 
                              color: isSavedStatus ? Colors.green : SymptomColours.warning
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._buildSymptomCards(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveSymptoms,
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                    label: const Text(
                      "Save Symptoms", 
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SymptomColours.button,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  List<Widget> _buildSymptomCards() {
    final periodSymptomsCard = SymptomCard(
      title: "Period Symptoms",
      categoryIcon: Icons.water_drop,
      categoryColor: Colors.pinkAccent,
      options: periodSymptomsOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Period Symptoms"),
      isSingleChoice: false,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Period Symptoms", periodSymptomsOptions, false),
      initiallyExpanded: widget.isPeriod,
    );

    final ovulationSymptomsCard = SymptomCard(
      title: "Ovulation Symptoms",
      categoryIcon: Icons.filter_vintage,
      categoryColor: Colors.deepPurpleAccent,
      options: ovulationSymptomsOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Ovulation Symptoms"),
      isSingleChoice: false,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Ovulation Symptoms", ovulationSymptomsOptions, false),
      initiallyExpanded: !widget.isPeriod,
    );

    final sexIntimacyCard = SymptomCard(
      title: "Sex & Intimacy",
      categoryIcon: Icons.favorite,
      categoryColor: Colors.pink,
      options: sexualActivityOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Sex & Intimacy"),
      isSingleChoice: true,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Sex & Intimacy", sexualActivityOptions, true),
    );

    final sexDriveCard = SymptomCard(
      title: "Sex Drive",
      categoryIcon: Icons.trending_up,
      categoryColor: Colors.orangeAccent,
      options: sexDriveOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Sex Drive"),
      isSingleChoice: true,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Sex Drive", sexDriveOptions, true),
    );

    final vaginalDischargeCard = SymptomCard(
      title: "Vaginal Discharge",
      categoryIcon: Icons.opacity,
      categoryColor: Colors.teal,
      options: vaginalDischargeOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Vaginal Discharge"),
      isSingleChoice: true,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Vaginal Discharge", vaginalDischargeOptions, true),
    );

    final pregnancyTestCard = SymptomCard(
      title: "Pregnancy Test",
      categoryIcon: Icons.medication,
      categoryColor: Colors.blueAccent,
      options: pregnancyTestOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Pregnancy Test"),
      isSingleChoice: true,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Pregnancy Test", pregnancyTestOptions, true),
    );

    final ovulationTestCard = SymptomCard(
      title: "Ovulation Test",
      categoryIcon: Icons.science,
      categoryColor: Colors.deepPurple,
      options: ovulationTestOptions,
      selectedOptions: _viewModel.getSelectedOptionsForCategory("Ovulation Test"),
      isSingleChoice: true,
      onOptionSelected: (opt) => _viewModel.handleOptionSelected(opt, "Ovulation Test", ovulationTestOptions, true),
    );

    final notesCard = _buildNotesCard();

    final otherLogsDivider = const Padding(
      padding: EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Center(
        child: Row(
          children: [
            Expanded(child: Divider(color: SymptomColours.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Other Logs",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SymptomColours.textSecondary,
                ),
              ),
            ),
            Expanded(child: Divider(color: SymptomColours.border)),
          ],
        ),
      ),
    );

    if (widget.isPeriod) {
      return [
        periodSymptomsCard,
        sexIntimacyCard,
        sexDriveCard,
        vaginalDischargeCard,
        notesCard,
        otherLogsDivider,
        ovulationSymptomsCard,
        pregnancyTestCard,
        ovulationTestCard,
        const SizedBox(height: 20),
      ];
    } else {
      return [
        ovulationSymptomsCard,
        vaginalDischargeCard,
        sexIntimacyCard,
        sexDriveCard,
        notesCard,
        otherLogsDivider,
        periodSymptomsCard,
        pregnancyTestCard,
        ovulationTestCard,
        const SizedBox(height: 20),
      ];
    }
  }

  Widget _buildNotesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SymptomColours.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SymptomColours.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.note_alt_outlined, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SymptomColours.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _noteController.text.isNotEmpty ? _noteController.text : "Explain further on how you feel...",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: SymptomColours.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: SymptomColours.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SymptomColours.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  onChanged: (val) => _viewModel.updateNote(val),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add your notes here...",
                    hintStyle: TextStyle(color: SymptomColours.textSecondary, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
