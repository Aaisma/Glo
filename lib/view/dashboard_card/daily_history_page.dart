import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../model/tracker_theme.dart';
import '../../viewmodel/period_view_model.dart';
import '../../viewmodel/ovulation_view_model.dart';

class DailyHistoryEntry {
  final DateTime date;
  final bool isPeriodLogged;
  final bool isOvulationLogged;
  final String? flow;
  final double? bbt;
  final String? sexDrive;
  final List<String> symptoms;
  final String? note;
  final Map<String, String> rawSymptoms; // To check categories like Tests

  DailyHistoryEntry({
    required this.date,
    required this.isPeriodLogged,
    required this.isOvulationLogged,
    this.flow,
    this.bbt,
    this.sexDrive,
    required this.symptoms,
    this.note,
    required this.rawSymptoms,
  });
}

class DailyHistoryPage extends StatefulWidget {
  final ThemeColors theme;
  const DailyHistoryPage({super.key, required this.theme});

  @override
  State<DailyHistoryPage> createState() => _DailyHistoryPageState();
}

class _DailyHistoryPageState extends State<DailyHistoryPage> {
  String _activeFilter = "All Logs";

  final List<String> _filters = [
    "All Logs",
    "Period",
    "Ovulation",
    "Symptoms",
    "Tests",
    "Notes"
  ];

  List<DailyHistoryEntry> _getMergedEntries(BuildContext context) {
    final periodViewModel = context.watch<PeriodViewModel>();
    final ovulationViewModel = context.watch<OvulationViewModel>();

    final Map<String, DailyHistoryEntry> merged = {};

    for (final pl in periodViewModel.logs) {
      final key = DateFormat('yyyy-MM-dd').format(pl.date);
      final rawSyms = <String, String>{};
      final displaySyms = <String>[];
      for (final entry in pl.symptoms.entries) {
        if (entry.value) {
          final parts = entry.key.split('_');
          final category = parts.length > 1 ? parts[0] : "Symptom";
          final label = parts.length > 1 ? parts[1] : parts[0];
          rawSyms[entry.key] = category;
          displaySyms.add(label);
        }
      }

      merged[key] = DailyHistoryEntry(
        date: pl.date,
        isPeriodLogged: pl.isPeriodDay,
        isOvulationLogged: false,
        flow: pl.flow,
        bbt: pl.bbt,
        symptoms: displaySyms,
        note: pl.note,
        rawSymptoms: rawSyms,
      );
    }

    for (final ol in ovulationViewModel.logs) {
      final key = DateFormat('yyyy-MM-dd').format(ol.date);
      final rawSyms = <String, String>{};
      final displaySyms = <String>[];
      for (final entry in ol.symptoms.entries) {
        if (entry.value) {
          final parts = entry.key.split('_');
          final category = parts.length > 1 ? parts[0] : "Symptom";
          final label = parts.length > 1 ? parts[1] : parts[0];
          rawSyms[entry.key] = category;
          displaySyms.add(label);
        }
      }

      if (merged.containsKey(key)) {
        final existing = merged[key]!;
        merged[key] = DailyHistoryEntry(
          date: existing.date,
          isPeriodLogged: existing.isPeriodLogged,
          isOvulationLogged: ol.isOvulationDay || ol.isFertileWindow,
          flow: existing.flow,
          bbt: ol.bbt ?? existing.bbt,
          sexDrive: ol.sexDrive,
          symptoms: {...existing.symptoms, ...displaySyms}.toList(),
          note: (ol.note != null && ol.note!.isNotEmpty) ? ol.note : existing.note,
          rawSymptoms: {...existing.rawSymptoms, ...rawSyms},
        );
      } else {
        merged[key] = DailyHistoryEntry(
          date: ol.date,
          isPeriodLogged: false,
          isOvulationLogged: ol.isOvulationDay || ol.isFertileWindow,
          bbt: ol.bbt,
          sexDrive: ol.sexDrive,
          symptoms: displaySyms,
          note: ol.note,
          rawSymptoms: rawSyms,
        );
      }
    }

    final list = merged.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));

    // Apply filters
    return list.where((entry) {
      switch (_activeFilter) {
        case "Period":
          return entry.isPeriodLogged || entry.flow != null;
        case "Ovulation":
          return entry.isOvulationLogged || entry.sexDrive != null;
        case "Symptoms":
          return entry.symptoms.any((sym) =>
              !entry.rawSymptoms.keys.any((key) =>
                  (key.contains("Test_") || key.startsWith("Pregnancy Test") || key.startsWith("Ovulation Test")) &&
                  entry.rawSymptoms[key] != null));
        case "Tests":
          return entry.rawSymptoms.keys.any((key) =>
              key.startsWith("Pregnancy Test") ||
              key.startsWith("Ovulation Test") ||
              key.contains("Test_"));
        case "Notes":
          return entry.note != null && entry.note!.isNotEmpty;
        case "All Logs":
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entries = _getMergedEntries(context);

    return Scaffold(
      backgroundColor: widget.theme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: widget.theme.headerText),
        title: Text(
          "Daily History",
          style: TextStyle(
            color: widget.theme.headerText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isActive = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isActive ? Colors.white : widget.theme.headerText,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    selected: isActive,
                    selectedColor: widget.theme.headerText,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: widget.theme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _activeFilter = filter;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: widget.theme.border),
                        const SizedBox(height: 12),
                        Text(
                          "No entries found under \"$_activeFilter\"",
                          style: const TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildTimelineItem(entry);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(DailyHistoryEntry entry) {
    final formattedDate = DateFormat('EEEE, MMMM dd, yyyy').format(entry.date);
    
    // Check what is logged
    final details = <Widget>[];

    if (entry.isPeriodLogged) {
      details.add(_buildDetailRow(Icons.check_circle, "Period Logged", color: const Color(0xFFE94B64)));
    }
    if (entry.isOvulationLogged) {
      details.add(_buildDetailRow(Icons.stars, "Ovulation Logged", color: const Color(0xFF4CAF50)));
    }
    if (entry.flow != null) {
      details.add(_buildDetailRow(Icons.water_drop, "Flow: ${entry.flow}", color: const Color(0xFFE94B64)));
    }
    if (entry.bbt != null) {
      details.add(_buildDetailRow(Icons.thermostat, "BBT: ${entry.bbt!.toStringAsFixed(2)} °F", color: Colors.orange));
    }
    if (entry.sexDrive != null) {
      details.add(_buildDetailRow(Icons.favorite, "Sex Drive: ${entry.sexDrive}", color: Colors.pink));
    }
    
    // Symptoms (filter out tests from regular symptoms display in this list if desired, or show all)
    if (entry.symptoms.isNotEmpty) {
      final symptomChips = entry.symptoms.map((s) {
        return Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.theme.lightCircle.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.theme.border),
          ),
          child: Text(
            s,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        );
      }).toList();

      details.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Symptoms:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 4),
              Wrap(children: symptomChips),
            ],
          ),
        ),
      );
    }

    if (entry.note != null && entry.note!.isNotEmpty) {
      details.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: widget.theme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes, size: 12, color: Colors.orange),
                    SizedBox(width: 4),
                    Text("Note", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(entry.note!, style: const TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.theme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Date block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.theme.lightCircle,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                color: widget.theme.headerText,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
