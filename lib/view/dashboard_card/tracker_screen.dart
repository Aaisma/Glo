import 'package:flutter/material.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  bool isPeriodTracker = true; // true = Period, false = Ovulation

  // Reusing the AD/BS dates array structure
  final List<List<Map<String, dynamic>>> dates = [
    [
      {"en": "", "np": "", "selected": false},
      {"en": "", "np": "", "selected": false},
      {"en": "", "np": "", "selected": false},
      {"en": "1", "np": "१८", "selected": false},
      {"en": "2", "np": "१९", "selected": false},
      {"en": "3", "np": "२०", "selected": false},
      {"en": "4", "np": "२१", "selected": false},
    ],
    [
      {"en": "5", "np": "२२", "selected": false},
      {"en": "6", "np": "२३", "selected": false},
      {"en": "7", "np": "२४", "selected": false},
      {"en": "8", "np": "२५", "marker": "Cycle Day 4", "selected": false},
      {"en": "9", "np": "२६", "selected": false},
      {"en": "10", "np": "२७", "selected": false},
      {"en": "11", "np": "२८", "selected": false},
    ],
    [
      {"en": "12", "np": "२९", "marker": "Start", "selected": false},
      {"en": "13", "np": "३०", "selected": false},
      {"en": "14", "np": "३१", "selected": false},
      {"en": "15", "np": "१", "selected": false},
      {"en": "16", "np": "२", "selected": false},
      {"en": "17", "np": "३", "selected": false},
      {"en": "18", "np": "४", "selected": false},
    ],
    [
      {"en": "19", "np": "५", "selected": false},
      {"en": "20", "np": "६", "selected": false},
      {"en": "21", "np": "७", "selected": false},
      {"en": "22", "np": "८", "selected": false},
      {"en": "23", "np": "९", "selected": false},
      {"en": "24", "np": "१०", "selected": false},
      {"en": "25", "np": "११", "selected": false},
    ],
    [
      {"en": "26", "np": "१२", "marker": "PMS", "selected": false},
      {"en": "27", "np": "१३", "selected": false},
      {"en": "28", "np": "१४", "selected": false},
      {"en": "29", "np": "१५", "selected": false},
      {"en": "30", "np": "१६", "selected": false},
      {"en": "31", "np": "१७", "marker": "Appointment", "selected": false},
      {"en": "", "np": "", "selected": false},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        title: _buildToggle(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCalendarSection(),
              const SizedBox(height: 24),
              _buildSymptomsSection(),
              const SizedBox(height: 24),
              _buildCycleHistorySection(),
              const SizedBox(height: 24),
              _buildCycleNotesSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => isPeriodTracker = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: !isPeriodTracker ? const Color(0xFFA8E6A1) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                "Ovulation",
                style: TextStyle(
                  color: !isPeriodTracker ? Colors.white : const Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => isPeriodTracker = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isPeriodTracker ? const Color(0xFFFD8CA1) : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                "Period",
                style: TextStyle(
                  color: isPeriodTracker ? Colors.white : const Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final isPink = isPeriodTracker;
    final accentColor = isPink ? const Color(0xFFFD8CA1) : const Color(0xFFA8E6A1);
    final daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: Color(0xFF666666)),
              Text(
                "May 2024 / जेठ २०८१",
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF666666)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek.map((d) => Text(d, style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.bold))).toList(),
          ),
          const SizedBox(height: 8),
          Column(
            children: dates.map((week) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: week.map((day) {
                  bool hasData = day["en"]!.isNotEmpty;
                  bool isSelected = day["selected"] ?? false;
                  
                  int dayNumber = hasData ? int.tryParse(day["en"]!) ?? 0 : 0;
                  
                  Color bgColor = Colors.transparent;
                  Color textColor = const Color(0xFF333333);
                  Color nepaliColor = const Color(0xFF666666);
                  Widget? extraMarker;

                  if (hasData) {
                    if (isPink) {
                      if (dayNumber >= 10 && dayNumber <= 14) {
                        bgColor = const Color(0xFFF3EDED); // Pre-period phase
                      } else if (dayNumber >= 15 && dayNumber <= 19) {
                        extraMarker = Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE94B64), // Red dots for period
                            shape: BoxShape.circle,
                          ),
                        );
                      }
                    } else {
                      if (dayNumber >= 12 && dayNumber <= 16) {
                        bgColor = const Color(0xFFC8F2C4); // Fertile window
                      } else if (dayNumber == 14) {
                        bgColor = const Color(0xFF4CAF50); // Ovulation day
                        textColor = Colors.white;
                        nepaliColor = Colors.white70;
                      }
                    }
                    
                    if (isSelected) {
                        bgColor = isPink ? const Color(0xFFE94B64) : const Color(0xFF4CAF50);
                        textColor = Colors.white;
                        nepaliColor = Colors.white70;
                    }
                  }

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (hasData) {
                          setState(() {
                            day["selected"] = !isSelected;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day["en"]!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              day["np"]!,
                              style: TextStyle(
                                color: nepaliColor,
                                fontSize: 10,
                              ),
                            ),
                            if (extraMarker != null) ...[
                              const SizedBox(height: 2),
                              extraMarker,
                            ] else
                              const SizedBox(height: 8), // Keep fixed height
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    final isPink = isPeriodTracker;
    final cardColor = isPink ? const Color(0xFFF7C6D0) : const Color(0xFFDFF6DD);
    final symptoms = isPink 
        ? ['Flow', 'Cramps', 'Bloating', 'Fatigue', 'Acne', 'Breast Tenderness']
        : ['Cervical Mucus', 'Ovulation Pain', 'Libido', 'Breast Tenderness', 'Bloating'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Log Symptoms",
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Other Symptoms →",
                style: TextStyle(color: isPink ? const Color(0xFFFD8CA1) : const Color(0xFFA8E6A1)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: symptoms.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    symptoms[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPink ? const Color(0xFFFD8CA1) : const Color(0xFFA8E6A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
                child: const Text("Log BBT", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPink ? const Color(0xFFFD8CA1) : const Color(0xFFA8E6A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {},
                child: Text(isPink ? "Log Flow" : "Log Sex Drive", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCycleHistorySection() {
    final isPink = isPeriodTracker;
    final accentColor = isPink ? const Color(0xFFFD8CA1) : const Color(0xFFA8E6A1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cycle History",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPink ? Icons.water_drop : Icons.wb_sunny,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPink ? "Oct 12 - Oct 16" : "Oct 24 - Oct 29 (Fertile)",
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPink ? "5 days • Medium Flow • Cramps" : "Ovulation: Oct 27 • High Libido",
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleNotesSection() {
    final isPink = isPeriodTracker;
    final bgColor = isPink ? const Color(0xFFFCE8EB) : const Color(0xFFE9FBE7);
    final buttonColor = isPink ? const Color(0xFFE94B64) : const Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cycle Notes",
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Add your notes here...",
                  hintStyle: TextStyle(color: Color(0xFF666666)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {},
                    child: const Text("Save Note", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
