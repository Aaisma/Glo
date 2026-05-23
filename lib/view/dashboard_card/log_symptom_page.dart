import 'package:flutter/material.dart';
import '../components/symptom_category_widget.dart';

class LogSymptomsPage extends StatefulWidget {
  const LogSymptomsPage({super.key});

  @override
  State<LogSymptomsPage> createState() => _LogSymptomsPageState();
}

class _LogSymptomsPageState extends State<LogSymptomsPage> {
  final Set<String> _selectedSymptoms = {};

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Log Symptoms", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              SymptomCategoryWidget(
                title: "Period Symptoms",
                selectedSymptoms: _selectedSymptoms,
                onSymptomToggled: _toggleSymptom,
                items: const [
                  {'name': 'Cramps', 'icon': Icons.bolt},
                  {'name': 'Headache', 'icon': Icons.sentiment_dissatisfied},
                  {'name': 'Tender Breasts', 'icon': Icons.favorite_border},
                  {'name': 'Backache', 'icon': Icons.airline_seat_flat},
                  {'name': 'Fatigue', 'icon': Icons.bedtime},
                  {'name': 'Nausea', 'icon': Icons.sick},
                  {'name': 'Acne', 'icon': Icons.face},
                  {'name': 'Bloating', 'icon': Icons.bubble_chart},
                ],
              ),
              SymptomCategoryWidget(
                title: "Ovulation Symptoms",
                selectedSymptoms: _selectedSymptoms,
                onSymptomToggled: _toggleSymptom,
                items: const [
                  {'name': 'Stretchy Discharge', 'icon': Icons.water_drop},
                  {'name': 'Watery Discharge', 'icon': Icons.water_drop_outlined},
                  {'name': 'Sticky Discharge', 'icon': Icons.grain},
                  {'name': 'Spotting', 'icon': Icons.fiber_manual_record},
                  {'name': 'High Sex Drive', 'icon': Icons.local_fire_department},
                  {'name': 'Pelvic Pain', 'icon': Icons.healing},
                ],
              ),
              SymptomCategoryWidget(
                title: "Sex & Intimacy",
                selectedSymptoms: _selectedSymptoms,
                onSymptomToggled: _toggleSymptom,
                items: const [
                  {'name': 'Protected', 'icon': Icons.security},
                  {'name': 'Unprotected', 'icon': Icons.warning_amber},
                  {'name': 'Masturbation', 'icon': Icons.pan_tool},
                  {'name': 'No Sex', 'icon': Icons.block},
                ],
              ),
              SymptomCategoryWidget(
                title: "Mood",
                selectedSymptoms: _selectedSymptoms,
                onSymptomToggled: _toggleSymptom,
                items: const [
                  {'name': 'Calm', 'icon': Icons.sentiment_satisfied},
                  {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied},
                  {'name': 'Sad', 'icon': Icons.sentiment_very_dissatisfied},
                  {'name': 'Mood Swings', 'icon': Icons.compare_arrows},
                  {'name': 'Irritated', 'icon': Icons.mood_bad},
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
