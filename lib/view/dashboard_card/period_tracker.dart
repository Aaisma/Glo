import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import 'log_symptoms_page.dart';

class PeriodTrackerView extends StatelessWidget {
  const PeriodTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PeriodViewModel>();
    final theme = periodTheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            _buildInteractiveCalendar(context, viewModel, theme),
            const SizedBox(height: 16),
            _buildOtherSymptomsButton(context, theme),
            const SizedBox(height: 12),
            _buildSymptomCards(viewModel, theme),
            const SizedBox(height: 16),
            _buildLogButtons(context, viewModel, theme),
            const SizedBox(height: 16),
            _buildCycleHistory(viewModel, theme),
            const SizedBox(height: 16),
            _buildCycleNotes(context, viewModel, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCalendar(BuildContext context, PeriodViewModel viewModel, ThemeColors theme) {
    final now = viewModel.currentMonth;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)
    
    // Adjust weekday to match Sunday as first day of week (0)
    final offset = firstWeekday == 7 ? 0 : firstWeekday;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDED), // Light pink pre-period phase as requested
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
                onPressed: () => viewModel.changeMonth(-1),
              ),
              Text(
                DateFormat('MMMM yyyy').format(now),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.headerText,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: theme.headerText,
                onPressed: () => viewModel.changeMonth(1),
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
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              if (index < offset || index >= daysInMonth + offset) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - offset + 1;
              final currentDate = DateTime(now.year, now.month, dayNumber);
              
              // Find log for this date
              final log = viewModel.logs.firstWhere((l) => 
                l.date.year == currentDate.year && 
                l.date.month == currentDate.month && 
                l.date.day == currentDate.day, 
                orElse: () => throw Exception() // Handled below
              );
              final isPeriodDay = log != null ? log.isPeriodDay : false;

              final isSelected = viewModel.selectedDate.year == currentDate.year &&
                                 viewModel.selectedDate.month == currentDate.month &&
                                 viewModel.selectedDate.day == currentDate.day;

              Color bgColor = Colors.transparent;
              Color textColor = const Color(0xFF333333);

              if (isPeriodDay) {
                bgColor = const Color(0xFFE94B64);
                textColor = Colors.white;
              }

              return GestureDetector(
                onTap: () => viewModel.selectDate(currentDate),
                onDoubleTap: () {
                  viewModel.selectDate(currentDate);
                  viewModel.togglePeriodDay();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                    border: isSelected ? Border.all(color: theme.headerText, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isPeriodDay || isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text("Double tap a date to mark/unmark period", style: TextStyle(fontSize: 10, color: Colors.black54)),
        ],
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
            "Other Symptoms >",
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
      {"icon": Icons.water_drop, "label": "Flow", "key": "Flow"},
      {"icon": Icons.sick, "label": "Cramps", "key": "Cramps"},
      {"icon": Icons.air, "label": "Bloating", "key": "Bloating"},
      {"icon": Icons.airline_seat_flat, "label": "Fatigue", "key": "Fatigue"},
      {"icon": Icons.face, "label": "Acne", "key": "Acne"},
      {"icon": Icons.favorite, "label": "Tender\nBreasts", "key": "Tender Breasts"},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        final key = item["key"] as String;
        final isActive = viewModel.logForSelectedDate?.symptoms[key] == true;

        return GestureDetector(
          onTap: () => viewModel.toggleSymptom(key),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? theme.headerText : const Color(0xFFF7C6D0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isActive ? theme.headerText : theme.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item["icon"] as IconData, color: isActive ? Colors.white : theme.headerText, size: 28),
                const SizedBox(height: 4),
                Text(
                  item["label"] as String,
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
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: ['Light', 'Medium', 'Heavy'].map((flow) {
                return RadioListTile<String>(
                  title: Text(flow),
                  value: flow,
                  groupValue: currentFlow,
                  activeColor: theme.headerText,
                  onChanged: (val) => setState(() => currentFlow = val!),
                );
              }).toList(),
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

  Widget _buildCycleHistory(PeriodViewModel viewModel, ThemeColors theme) {
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
                "Cycle History",
                style: TextStyle(
                  color: theme.headerText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (viewModel.logs.isEmpty)
             const Text("No history available yet.", style: TextStyle(color: Colors.black54)),
          ...viewModel.logs.where((l) => l.isPeriodDay).take(3).map((log) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMM dd, yyyy').format(log.date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF333333))),
                        Text(
                          log.flow != null ? "Flow: ${log.flow}" : "No flow logged",
                          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.circle, color: theme.darkCircle, size: 10),
                  const SizedBox(width: 4),
                  const Text("1 Day", style: TextStyle(fontSize: 11)),
                ],
              ),
            );
          }),
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
}
