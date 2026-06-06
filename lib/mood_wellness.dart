import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodWellnessScreen extends StatefulWidget {
  const MoodWellnessScreen({super.key});

  @override
  State<MoodWellnessScreen> createState() => _MoodWellnessScreenState();
}

class _MoodWellnessScreenState extends State<MoodWellnessScreen> {
  static const Color primaryColor = Color(0xFFFF3E63);
  static const Color backgroundColor = Color(0xFFFFF6F8);

  int selectedMood = -1;
  final Set<String> selectedSymptoms = {};
  final TextEditingController journalController = TextEditingController();

  final List<Map<String, String>> moods = [
    {"emoji": "🤩", "label": "Amazing"},
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😌", "label": "Calm"},
    {"emoji": "😴", "label": "Tired"},
    {"emoji": "😔", "label": "Sad"},
    {"emoji": "😠", "label": "Angry"},
  ];

  final List<String> symptoms = [
    "Bloating",
    "Headache",
    "Acne",
    "Low Energy",
    "Cramps",
    "Mood Swings",
    "Stress",
    "Anxiety",
  ];

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMoodCard(),
              const SizedBox(height: 20),
              _buildSymptomsCard(),
              const SizedBox(height: 20),
              _buildJournalCard(),
              const SizedBox(height: 20),
              _buildWellnessCard(),
              const SizedBox(height: 20),
              _buildWeeklyMoodCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 260,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFE6EC),
            Color(0xFFFFF6F8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [softShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            right: 40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 70,
            right: 25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.7),
              ),
              child: Icon(
                Icons.self_improvement_rounded,
                size: 55,
                color: primaryColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _iconButton(Icons.arrow_back_ios_rounded),
                    const Spacer(),
                    _iconButton(Icons.notifications_none_rounded),
                    const SizedBox(width: 10),
                    _iconButton(Icons.history_rounded),
                  ],
                ),
                const SizedBox(height: 35),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Good Morning lady🌸",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Every feeling matters today.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [softShadow],
      ),
      child: Icon(icon, color: Colors.black87),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "How are you feeling today?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            itemCount: moods.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 120,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final mood = moods[index];
              final selected = selectedMood == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = index;
                  });
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: selected ? 78 : 70,
                      height: selected ? 78 : 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? primaryColor.withOpacity(0.15)
                            : const Color(0xFFFFF3F6),
                        border: Border.all(
                          color: selected
                              ? primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [softShadow],
                      ),
                      child: Center(
                        child: Text(
                          mood["emoji"]!,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mood["label"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Track Symptoms",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: symptoms.map((symptom) {
              final selected =
              selectedSymptoms.contains(symptom);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      selectedSymptoms.remove(symptom);
                    } else {
                      selectedSymptoms.add(symptom);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? primaryColor
                        : const Color(0xFFFFEEF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.menu_book_rounded,
                color: primaryColor,
              ),
              SizedBox(width: 10),
              Text(
                "Talk About Your Day",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                TextField(
                  controller: journalController,
                  minLines: 5,
                  maxLines: 7,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "Write about your thoughts, emotions and experiences...",
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${journalController.text.length} characters",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessCard() {
    final items = [
      {
        "title": "Sleep",
        "value": "7.5 hrs",
        "progress": 0.75,
        "icon": Icons.bedtime_rounded,
      },
      {
        "title": "Water Intake",
        "value": "2.1 L",
        "progress": 0.65,
        "icon": Icons.water_drop_rounded,
      },
      {
        "title": "Rest",
        "value": "80%",
        "progress": 0.80,
        "icon": Icons.spa_rounded,
      },
      {
        "title": "Energy",
        "value": "90%",
        "progress": 0.90,
        "icon": Icons.bolt_rounded,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Wellness",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item["icon"] as IconData,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item["value"] as String,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 55,
                    height: 55,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value:
                          item["progress"] as double,
                          strokeWidth: 8,
                          color: primaryColor,
                          backgroundColor:
                          primaryColor.withOpacity(0.15),
                        ),
                        Text(
                          "${((item["progress"] as double) * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyMoodCard() {
    const emojis = [
      "😊",
      "😄",
      "😌",
      "🤩",
      "😊",
      "😍",
      "😄",
    ];

    return Container(
      height: 420,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Mood This Week",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 8,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: primaryColor,
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                          primaryColor.withOpacity(0.1),
                        ),
                        spots: const [
                          FlSpot(0, 4),
                          FlSpot(1, 5),
                          FlSpot(2, 3),
                          FlSpot(3, 6),
                          FlSpot(4, 5),
                          FlSpot(5, 7),
                          FlSpot(6, 6),
                        ],
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: primaryColor,
                              strokeWidth: 3,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      topTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),
                      rightTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),
                      leftTitles:
                      const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget:
                              (value, meta) {
                            const days = [
                              "Mon",
                              "Tue",
                              "Wed",
                              "Thu",
                              "Fri",
                              "Sat",
                              "Sun"
                            ];

                            return Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 10),
                              child: Text(
                                days[value.toInt()],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width =
                            constraints.maxWidth;
                        final height =
                            constraints.maxHeight;

                        final points = [
                          4.0,
                          5.0,
                          3.0,
                          6.0,
                          5.0,
                          7.0,
                          6.0
                        ];

                        return Stack(
                          children: List.generate(
                            points.length,
                                (index) {
                              final x =
                                  (width / 6) * index;
                              final y =
                                  height -
                                      ((points[index] /
                                          8) *
                                          height) -
                                      40;

                              return Positioned(
                                left: x - 10,
                                top: y,
                                child: Text(
                                  emojis[index],
                                  style:
                                  const TextStyle(
                                    fontSize: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}