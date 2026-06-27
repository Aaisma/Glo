import 'package:flutter/material.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {

  final List<List<Map<String, String>>> dates = [
    [
      {"en": "", "np": ""},
      {"en": "", "np": ""},
      {"en": "", "np": ""},
      {"en": "1", "np": "१८"},
      {"en": "2", "np": "१९"},
      {"en": "3", "np": "२०"},
      {"en": "4", "np": "२१"},
    ],
    [
      {"en": "5", "np": "२२"},
      {"en": "6", "np": "२३"},
      {"en": "7", "np": "२४"},
      {"en": "8", "np": "२५", "marker": "Cycle Day 4"},
      {"en": "9", "np": "२६"},
      {"en": "10", "np": "२७"},
      {"en": "11", "np": "२८"},
    ],
    [
      {"en": "12", "np": "२९", "marker": "Start"},
      {"en": "13", "np": "३०"},
      {"en": "14", "np": "३१"},
      {"en": "15", "np": "१"},
      {"en": "16", "np": "२"},
      {"en": "17", "np": "३"},
      {"en": "18", "np": "४"},
    ],
    [
      {"en": "19", "np": "५"},
      {"en": "20", "np": "६"},
      {"en": "21", "np": "७"},
      {"en": "22", "np": "८"},
      {"en": "23", "np": "९"},
      {"en": "24", "np": "१०"},
      {"en": "25", "np": "११"},
    ],
    [
      {"en": "26", "np": "१२", "marker": "PMS"},
      {"en": "27", "np": "१३"},
      {"en": "28", "np": "१४"},
      {"en": "29", "np": "१५"},
      {"en": "30", "np": "१६"},
      {"en": "31", "np": "१७", "marker": "Appointment"},
      {"en": "", "np": ""},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        title: const Text("My Calendar"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          // Month name header
          const SizedBox(height: 12),
          const Text(
            "May 2024 / जेठ २०८१",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 12),

          // Weekday row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),

          // Calendar grid (half screen)
          Expanded(
            flex: 1,
            child: Column(
              children: dates.map((week) {
                return Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: week.map((day) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: day["en"]!.isEmpty
                                ? Colors.transparent
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day["en"]!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                day["np"]!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              if (day.containsKey("marker"))
                                Text(
                                  day["marker"]!,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notes section (half screen, redesigned)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade50, Colors.pink.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Notes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Write your notes here...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.pink.shade200),
                      ),
                      contentPadding: const EdgeInsets.all(8),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  // Example notes with icons
                  const Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text("Cramps and fatigue today"),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.local_drink, color: Colors.blue, size: 16),
                      SizedBox(width: 6),
                      Text("Drank 2.5L of water"),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.spa, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text("Used new skincare product"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
