import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import '../../model/tracker_theme.dart';
import '../../model/period_log_model.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/tracker_navigation_view_model.dart';
import 'log_symptoms_page.dart';

class PeriodTrackerView extends StatelessWidget {
  const PeriodTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PeriodViewModel>();
    final navViewModel = context.watch<TrackerNavigationViewModel>();
    final isNepali = navViewModel.isNepaliCalendar;
    final theme = periodTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              "Period Tracker",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.headerText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Track your menstrual cycle",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: theme.border, width: double.infinity),
            const SizedBox(height: 16),
            _buildSummaryCard(viewModel, theme, isNepali),
            _buildInteractiveCalendar(context, viewModel, theme),
            _buildPredictionsCard(viewModel, theme, isNepali),
            const SizedBox(height: 16),
            _buildOtherSymptomsButton(context, theme),
            const SizedBox(height: 12),
            _buildSymptomCards(viewModel, theme),
            const SizedBox(height: 16),
            _buildLogButtons(context, viewModel, theme),
            const SizedBox(height: 16),
            _buildCycleHistory(viewModel, theme, isNepali),
            const SizedBox(height: 16),
            _buildCycleNotes(context, viewModel, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSymptomsButton(BuildContext context, ThemeColors theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LogSymptomsPage(isPeriod: true)));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            "More Symptoms >",
            style: TextStyle(
              color: theme.headerText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomCards(PeriodViewModel viewModel, ThemeColors theme) {
    final items = [
      {"label": "Cramps", "icon": Icons.sick, "key": "Cramps"},
      {"label": "Bloating", "icon": Icons.air, "key": "Bloating"},
      {"label": "Fatigue", "icon": Icons.battery_alert, "key": "Fatigue"},
      {"label": "Acne", "icon": Icons.face, "key": "Acne"},
      {"label": "Tender Breast", "icon": Icons.favorite, "key": "Tender Breast"},
      {"label": "Headache", "icon": Icons.face_retouching_off, "key": "Headache"},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        final key = item["key"] as String;
        final label = item["label"] as String;
        final icon = item["icon"] as IconData;
        final dbKey = "Period Symptoms_$key";
        final isActive = viewModel.logForSelectedDate?.symptoms[dbKey] == true;

        return GestureDetector(
          onTap: () => viewModel.toggleSymptom(dbKey),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? theme.headerText : const Color(0xFFFDE8EB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isActive ? theme.headerText : theme.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: isActive ? Colors.white : theme.headerText, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: isActive ? Colors.white : const Color(0xFF333333)
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogButtons(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
               // Show dialog to enter BBT
               _showBBTDialog(context, viewModel, theme);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFD8CA1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.thermostat, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text("Log BBT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
               _showFlowDialog(context, viewModel, theme);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFD8CA1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text("Log Flow", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBBTDialog(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    double temp = viewModel.logForSelectedDate?.bbt ?? 98.6;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Log BBT for ${DateFormat('MMM dd').format(viewModel.selectedDate)}"),
          content: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${temp.toStringAsFixed(1)} °F", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Slider(
                  value: temp,
                  min: 96.0,
                  max: 100.0,
                  divisions: 40,
                  activeColor: theme.headerText,
                  onChanged: (val) => setState(() => temp = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.buttonBg),
              onPressed: () {
                viewModel.updateBBT(temp);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  void _showFlowDialog(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    String currentFlow = viewModel.logForSelectedDate?.flow ?? 'Light';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Log Flow for ${DateFormat('MMM dd').format(viewModel.selectedDate)}"),
          content: StatefulBuilder(
            builder: (context, setState) => RadioGroup<String>(
              groupValue: currentFlow,
              onChanged: (val) => setState(() => currentFlow = val!),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Light', 'Medium', 'Heavy'].map((flow) {
                  return RadioListTile<String>(
                    title: Text(flow),
                    value: flow,
                    activeColor: theme.headerText,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.buttonBg),
              onPressed: () {
                viewModel.updateFlow(currentFlow);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  Widget _buildCycleHistory(PeriodViewModel viewModel, ThemeColors theme, bool isNepali) {
    final lastPeriodStart = viewModel.lastPeriodStart;
    
    final String dateStr;
    if (lastPeriodStart != null) {
      dateStr = isNepali 
          ? NepaliDateFormat('MMMM d, yyyy', Language.nepali).format(NepaliDateTime.fromDateTime(lastPeriodStart))
          : DateFormat('MMMM dd, yyyy').format(lastPeriodStart);
    } else {
      dateStr = isNepali ? "हालसम्म कुनै डेटा उपलब्ध छैन" : "No history available yet";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note, color: theme.headerText),
              const SizedBox(width: 8),
              Text(
                isNepali ? "महिनावारी इतिहास" : "Cycle History",
                style: TextStyle(
                  color: theme.headerText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNepali ? "अन्तिम महिनावारी सुरु मिति:" : "Last Period Start Date:",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
              ),
              Text(
                dateStr,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.headerText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleNotes(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    final noteController = TextEditingController(text: viewModel.logForSelectedDate?.note);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: theme.headerText),
              const SizedBox(width: 8),
              Text(
                "Cycle Notes",
                style: TextStyle(
                  color: theme.headerText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.border),
            ),
            child: TextField(
              controller: noteController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Write your note here...",
                hintStyle: TextStyle(color: Colors.black54),
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // View history dummy action
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History feature coming soon!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.headerText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: theme.headerText)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                ),
                child: const Text("See History", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.saveNote(noteController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Saved!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94B64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Save Note", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PeriodViewModel viewModel, ThemeColors theme, bool isNepali) {
    final analytics = viewModel.analyticsResult;
    if (analytics == null) return const SizedBox.shrink();

    String phaseEmoji = "🥚";
    if (analytics.currentPhase == "Menstruation") phaseEmoji = "🌸";
    if (analytics.currentPhase == "Ovulation") phaseEmoji = "⭐";
    if (analytics.currentPhase == "Fertile Window") phaseEmoji = "🌱";

    final cycleDayText = isNepali
        ? "चक्रको दिन ${_toNepaliDigits(analytics.currentCycleDay.toString())}"
        : "Day ${analytics.currentCycleDay} of cycle";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.lightCircle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(phaseEmoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translatePhase(analytics.currentPhase, isNepali),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.headerText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cycleDayText,
                    style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          Text(
            _translatePredictedEvent(analytics.nextPredictedEventText, isNepali),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.headerText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsCard(PeriodViewModel viewModel, ThemeColors theme, bool isNepali) {
    final analytics = viewModel.analyticsResult;
    if (analytics == null) return const SizedBox.shrink();

    final nextPeriodStr = analytics.lastPeriodStartDate != null
        ? (isNepali 
            ? NepaliDateFormat('MMMM d', Language.nepali).format(NepaliDateTime.fromDateTime(analytics.lastPeriodStartDate!.add(Duration(days: analytics.averageCycleLength))))
            : DateFormat('MMM dd').format(analytics.lastPeriodStartDate!.add(Duration(days: analytics.averageCycleLength))))
        : "--";
        
    final nextOvulationStr = analytics.lastPeriodStartDate != null
        ? (isNepali
            ? NepaliDateFormat('MMMM d', Language.nepali).format(NepaliDateTime.fromDateTime(analytics.lastPeriodStartDate!.add(Duration(days: analytics.averageCycleLength)).subtract(const Duration(days: 14))))
            : DateFormat('MMM dd').format(analytics.lastPeriodStartDate!.add(Duration(days: analytics.averageCycleLength)).subtract(const Duration(days: 14))))
        : "--";

    final cycleLengthVal = isNepali 
        ? "${_toNepaliDigits(analytics.averageCycleLength.toString())} दिन" 
        : "${analytics.averageCycleLength} Days";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNepali ? "भविष्यवाणी" : "Predictions",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPredictionColumn(isNepali ? "अर्को महिनावारी" : "Next Period", nextPeriodStr, theme.headerText),
              Container(width: 1, height: 36, color: theme.border.withValues(alpha: 0.5)),
              _buildPredictionColumn(isNepali ? "अर्को डिम्बोत्सर्जन" : "Next Ovulation", nextOvulationStr, theme.headerText),
              Container(width: 1, height: 36, color: theme.border.withValues(alpha: 0.5)),
              _buildPredictionColumn(isNepali ? "चक्र अवधि" : "Cycle Length", cycleLengthVal, theme.headerText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildInteractiveCalendar(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    final navViewModel = context.watch<TrackerNavigationViewModel>();
    final isNepali = navViewModel.isNepaliCalendar;
    
    final now = viewModel.currentMonth;
    final int offset;
    final int daysInMonth;
    final String monthHeader;

    if (isNepali) {
      final currentNepali = NepaliDateTime.fromDateTime(now);
      final nepaliMonthName = NepaliDateFormat('MMMM yyyy', Language.nepali).format(currentNepali);
      final nepaliEnglishMonthName = NepaliDateFormat('MMMM yyyy', Language.english).format(currentNepali);
      monthHeader = "$nepaliMonthName ($nepaliEnglishMonthName)";

      final firstDay = NepaliDateTime(currentNepali.year, currentNepali.month, 1);
      offset = firstDay.weekday - 1; 
      daysInMonth = firstDay.totalDays;
    } else {
      monthHeader = DateFormat('MMMM yyyy').format(now);
      final firstDay = DateTime(now.year, now.month, 1);
      final firstWeekday = firstDay.weekday;
      offset = firstWeekday == 7 ? 0 : firstWeekday;
      daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: theme.headerText,
                onPressed: () {
                  if (isNepali) {
                    final currentNepali = NepaliDateTime.fromDateTime(now);
                    final prevNepali = _changeNepaliMonth(currentNepali, -1);
                    viewModel.setCurrentMonth(prevNepali.toDateTime());
                  } else {
                    viewModel.changeMonth(-1);
                  }
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      monthHeader,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.headerText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => navViewModel.toggleCalendarSystem(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.headerText.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isNepali ? "Switch to AD" : "Switch to BS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: theme.headerText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: theme.headerText,
                onPressed: () {
                  if (isNepali) {
                    final currentNepali = NepaliDateTime.fromDateTime(now);
                    final nextNepali = _changeNepaliMonth(currentNepali, 1);
                    viewModel.setCurrentMonth(nextNepali.toDateTime());
                  } else {
                    viewModel.changeMonth(1);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) {
              return Text(
                day,
                style: TextStyle(color: theme.headerText, fontWeight: FontWeight.bold, fontSize: 12),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              if (index < offset || index >= daysInMonth + offset) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - offset + 1;
              final DateTime currentDate;

              if (isNepali) {
                final currentNepali = NepaliDateTime.fromDateTime(now);
                currentDate = NepaliDateTime(currentNepali.year, currentNepali.month, dayNumber).toDateTime();
              } else {
                currentDate = DateTime(now.year, now.month, dayNumber);
              }

              final logList = viewModel.logs.where((l) => 
                l.date.year == currentDate.year && 
                l.date.month == currentDate.month && 
                l.date.day == currentDate.day
              );
              final log = logList.isNotEmpty ? logList.first : null;
              final isConfirmedPeriod = log != null ? log.isPeriodDay : false;

              final isPredictedPeriod = !isConfirmedPeriod && 
                  _isPredictedPeriodDay(
                    currentDate, 
                    viewModel.analyticsResult?.lastPeriodStartDate, 
                    viewModel.analyticsResult?.averageCycleLength ?? 28, 
                    viewModel.analyticsResult?.averagePeriodLength ?? 5
                  );

              final isSelected = viewModel.selectedDate.year == currentDate.year &&
                                 viewModel.selectedDate.month == currentDate.month &&
                                 viewModel.selectedDate.day == currentDate.day;

              Color bgColor = Colors.transparent;
              Color textColor = const Color(0xFF333333);
              Border? borderStyle;

              if (isConfirmedPeriod) {
                final dayIdx = _getPeriodDayIndex(currentDate, viewModel.logs);
                if (dayIdx == 1) {
                  bgColor = const Color(0xFFB71C1C); // Dark crimson
                  textColor = Colors.white;
                } else {
                  bgColor = const Color(0xFFFBD5DC); // Lighter pink
                  textColor = const Color(0xFFD64A62);
                }
              } else if (isPredictedPeriod) {
                borderStyle = Border.all(color: const Color(0xFFE94B64), width: 1.5, style: BorderStyle.solid);
                textColor = const Color(0xFFE94B64);
              }

              if (isSelected) {
                borderStyle = Border.all(color: theme.headerText, width: 2);
              }

              final String primaryText;
              final String secondaryText;

              if (isNepali) {
                primaryText = _toNepaliDigits(dayNumber.toString());
                secondaryText = currentDate.day.toString();
              } else {
                primaryText = dayNumber.toString();
                secondaryText = _toNepaliDigits(NepaliDateTime.fromDateTime(currentDate).day.toString());
              }

              return GestureDetector(
                onTap: () {
                  viewModel.selectDate(currentDate);
                  if (!isConfirmedPeriod) {
                    viewModel.logPeriodRange(currentDate, 5);
                    final message = isNepali ? "सफलतापूर्वक अपडेट भयो" : "Updated successfully";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  }
                },
                onDoubleTap: () {
                  viewModel.selectDate(currentDate);
                  viewModel.togglePeriodDay();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: borderStyle,
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        primaryText,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isConfirmedPeriod || isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          color: isConfirmedPeriod ? Colors.white70 : Colors.black38,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap an unlogged date to log range. Double tap to toggle individual days.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  String _toNepaliDigits(String input) {
    const nepaliDigits = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return input.codeUnits.map((char) {
      if (char >= 48 && char <= 57) {
        return nepaliDigits[char - 48];
      }
      return String.fromCharCode(char);
    }).join();
  }

  String _translatePredictedEvent(String text, bool isNepali) {
    if (!isNepali) return text;
    if (text.contains("expected in")) {
      final parts = text.split(" expected in ");
      final event = parts[0];
      final days = parts[1].replaceAll(" days", "");
      final nepaliEvent = event == "Period" ? "महिनावारी" : "डिम्बोत्सर्जन";
      final nepaliDays = _toNepaliDigits(days);
      return "$nepaliEvent $nepaliDays दिनमा";
    }
    if (text.contains("is today")) {
      if (text.contains("Ovulation")) return "डिम्बोत्सर्जन आज हो";
      if (text.contains("Period")) return "महिनावारी आज हो";
    }
    if (text.contains("is late")) {
      final days = text.replaceAll(RegExp(r'\D+'), "");
      return "महिनावारी ${_toNepaliDigits(days)} दिन ढिलो";
    }
    return text;
  }

  String _translatePhase(String phase, bool isNepali) {
    if (!isNepali) return phase;
    switch (phase) {
      case "Menstruation":
        return "महिनावारी";
      case "Follicular":
        return "कूपिक चरण";
      case "Fertile Window":
        return "उर्वर विन्डो";
      case "Ovulation":
        return "डिम्बोत्सर्जन";
      case "Luteal":
        return "लुटियल चरण";
      default:
        return phase;
    }
  }

  NepaliDateTime _changeNepaliMonth(NepaliDateTime current, int increment) {
    int newMonth = current.month + increment;
    int newYear = current.year;
    while (newMonth > 12) {
      newMonth -= 12;
      newYear += 1;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear -= 1;
    }
    return NepaliDateTime(newYear, newMonth, 1);
  }

  int _getPeriodDayIndex(DateTime date, List<PeriodLogModel> logs) {
    final periodDays = logs.where((l) => l.isPeriodDay).map((l) => DateTime(l.date.year, l.date.month, l.date.day)).toList();
    periodDays.sort((a, b) => a.compareTo(b));
    
    final target = DateTime(date.year, date.month, date.day);
    if (!periodDays.contains(target)) return 0;
    
    DateTime start = target;
    while (true) {
      final prev = start.subtract(const Duration(days: 1));
      if (periodDays.contains(prev)) {
        start = prev;
      } else {
        break;
      }
    }
    return target.difference(start).inDays + 1;
  }

  bool _isPredictedPeriodDay(DateTime date, DateTime? lastPeriodStart, int avgCycleLength, int avgPeriodLength) {
    if (lastPeriodStart == null) return false;
    final dNormalized = DateTime(date.year, date.month, date.day);
    final todayNormalized = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    if (dNormalized.isBefore(todayNormalized)) return false; 

    final daysDiff = dNormalized.difference(lastPeriodStart).inDays;
    if (daysDiff < 0) return false;

    final cycleIndex = daysDiff ~/ avgCycleLength;
    if (cycleIndex == 0) return false; 

    final cycleStart = lastPeriodStart.add(Duration(days: cycleIndex * avgCycleLength));
    final offsetInCycle = dNormalized.difference(cycleStart).inDays;
    
    return offsetInCycle >= 0 && offsetInCycle < avgPeriodLength;
  }

  void _showPeriodConfirmationDialog(BuildContext context, PeriodViewModel viewModel, DateTime date, ThemeColors theme) {
    int selectedLength = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.water_drop, color: Color(0xFFE94B64)),
                  SizedBox(width: 8),
                  Text("Period Started", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Log a new period starting on ${DateFormat('MMMM dd, yyyy').format(date)}?",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text("Length:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  RadioGroup<int>(
                    groupValue: selectedLength,
                    onChanged: (val) {
                      setState(() {
                        selectedLength = val!;
                      });
                    },
                    child: Column(
                      children: [5, 6, 7].map((len) {
                        return RadioListTile<int>(
                          title: Text("$len days"),
                          value: len,
                          activeColor: const Color(0xFFE94B64),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94B64),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    viewModel.logPeriodRange(date, selectedLength);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged $selectedLength days of period starting ${DateFormat('MMM dd').format(date)}')),
                    );
                  },
                  child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
