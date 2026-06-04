import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_colors.dart';
import 'models/mood_model.dart';
import 'models/symptom_model.dart';
import 'card/mood_card.dart';
import 'card/symptom_chip.dart';
import 'card/insight_card.dart';
import 'card/talk.dart';
import 'card/wellness_check.dart';

class MoodWellnessScreen extends StatefulWidget {
  const MoodWellnessScreen({super.key});

  @override
  State<MoodWellnessScreen> createState() => _MoodWellnessScreenState();
}

class _MoodWellnessScreenState extends State<MoodWellnessScreen> {
  late List<MoodModel> moods;
  late List<SymptomModel> symptoms;

  @override
  void initState() {
    super.initState();

    moods = [
      MoodModel(
        name: "Amazing",
        image: "assets/images/amazing.png",
        icon: Icons.auto_awesome,
        color: Colors.purple,
      ),
      MoodModel(
        name: "Happy",
        image: "assets/images/happy.png",
        icon: Icons.favorite,
        color: AppColors.pink,
      ),
      MoodModel(
        name: "Calm",
        image: "assets/images/calm.png",
        icon: Icons.spa,
        color: Colors.deepPurple,
      ),
      MoodModel(
        name: "Tired",
        image: "assets/images/tired.png",
        icon: Icons.bolt,
        color: Colors.orange,
        selected: true,
      ),
      MoodModel(
        name: "Sad",
        image: "assets/images/sad.png",
        icon: Icons.cloud,
        color: Colors.blue,
      ),
      MoodModel(
        name: "Angry",
        image: "assets/images/angry.png",
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),
    ];

    symptoms = [
      SymptomModel(title: "Cramps", icon: Icons.bolt, selected: true),
      SymptomModel(title: "Bloating", icon: Icons.bubble_chart),
      SymptomModel(title: "Headache", icon: Icons.psychology, selected: true),
      SymptomModel(title: "Acne", icon: Icons.face),
      SymptomModel(title: "Low Energy", icon: Icons.battery_1_bar, selected: true),
      SymptomModel(title: "Stress", icon: Icons.spa),
      SymptomModel(title: "Anxiety", icon: Icons.warning_amber, selected: true),
      SymptomModel(title: "Back Pain", icon: Icons.accessibility_new),
      SymptomModel(title: "Tender Breasts", icon: Icons.favorite_border),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [

            Positioned(
              top: 60,
              right: 10,
              child: Image.asset(
                'assets/images/flower.png', // <-- use your exact filename
                width: 140,
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 25),
                    const Text(
                      "How are you feeling today?",
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "💗 Your feelings matter, always ✨",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // Mood selector
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: moods.length,
                        itemBuilder: (_, index) {
                          return MoodCard(
                            mood: moods[index],
                            onTap: () {
                              setState(() {
                                for (var m in moods) {
                                  m.selected = false;
                                }
                                moods[index].selected = true;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.pink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 6),
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    // Symptoms section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Track your symptoms",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight
                              .bold),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("+ Add custom"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: symptoms.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3.1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (_, index) {
                        return SymptomChip(
                          symptom: symptoms[index],
                          onTap: () {
                            setState(() {
                              symptoms[index].selected =
                              !symptoms[index].selected;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    const InsightCard(),
                    const SizedBox(height: 18),

                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(
                            flex: 6,
                            child: TalkCard(),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: WellnessCheck(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Your mood this week",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 6,
                          minY: 1,
                          maxY: 5,

                          borderData: FlBorderData(show: false),

                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),

                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    "Sun",
                                    "Mon",
                                    "Tue",
                                    "Wed",
                                    "Thu",
                                    "Fri",
                                    "Sat"
                                  ];

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      days[value.toInt()],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: AppColors.pink,
                              barWidth: 4,

                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.pink.withOpacity(0.15),
                              ),

                              spots: const [
                                FlSpot(0, 4),
                                FlSpot(1, 2),
                                FlSpot(2, 4),
                                FlSpot(3, 1.5),
                                FlSpot(4, 3),
                                FlSpot(5, 5),
                                FlSpot(6, 3),
                              ],

                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "May 24",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Good Evening, Shiny 🌸",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.calendar_month, color: AppColors.pink),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.notifications_none, color: AppColors.pink),
        ),
      ],
    );
  }
}
