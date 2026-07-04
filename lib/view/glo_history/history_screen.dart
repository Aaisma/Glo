import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glo/view/glo_profile/glo_profile.dart';
import 'package:glo/view/navigation_icon/calendar_screen.dart';
import 'package:glo/view/components/top_navigation.dart';
import 'package:glo/view/components/bottom_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const Color pink = Color(0xFFE85D8A);
  static const Color softPink = Color(0xFFFFF7FA);
  static const Color iconBg = Color(0xFFFFEAF1);
  static const Color borderPink = Color(0xFFFFD6E2);
  static const Color dark = Color(0xFF14181F);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> historyItems = [
    {
      "id": "medication_history",
      "type": "medication",
      "title": "Medication History",
      "icon": Icons.medication_outlined,
      "content": [
        "Paracetamol - 500mg daily",
        "Vitamin D - Weekly dose",
        "Side effects: None",
      ],
      "details":
      "You’ve been consistent with your medication routine. No side effects reported. Keep hydration high and continue weekly Vitamin D doses.",
    },
    {
      "id": "visit_history",
      "type": "visit",
      "title": "Visit History",
      "icon": Icons.local_hospital_outlined,
      "content": [
        "Dr. Sharma - 12 May 2026",
        "Treatment: Acne therapy",
        "Follow-up: 20 June 2026",
      ],
      "details":
      "Your last visit focused on acne therapy. Follow-up scheduled for 20 June 2026. Consider tracking skin changes before the next visit.",
    },
    {
      "id": "cycle_history",
      "type": "cycle",
      "title": "Cycle History",
      "icon": Icons.calendar_month_outlined,
      "content": [
        "Last Period: 3 June 2026",
        "Duration: 5 days",
        "Irregularity: April shorter cycle",
      ],
      "details":
      "Cycle duration stable at 5 days. April showed a shorter cycle — monitor next two months for pattern consistency.",
    },
    {
      "id": "acne_history",
      "type": "acne",
      "title": "Acne History",
      "icon": Icons.face_retouching_natural_outlined,
      "content": [
        "Triggers: Stress, Oily Food",
        "Treatment: Salicylic Acid",
        "Severity: Moderate",
      ],
      "details":
      "Stress and oily food remain primary triggers. Continue using salicylic acid and maintain a balanced diet to reduce flare-ups.",
    },
    {
      "id": "mood_history",
      "type": "mood",
      "title": "Mood History",
      "icon": Icons.mood_outlined,
      "content": [
        "Average Mood: Calm",
        "Mood Swings: Mild",
        "Linked to Acne Flare-Ups",
      ],
      "details":
      "Mood stability improving. Mild swings linked to acne flare-ups. Mindfulness and hydration help maintain calmness.",
    },
    {
      "id": "journal_notes",
      "type": "journal",
      "title": "Journal Notes",
      "icon": Icons.menu_book_outlined,
      "content": [
        "Self-Care: Meditation, Hydration",
        "Lifestyle Log: 7 Entries This Week",
      ],
      "details":
      "Great consistency in journaling! Meditation and hydration are helping maintain balance. Keep logging daily reflections.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _syncHistoryToFirestore();
  }

  Future<void> _syncHistoryToFirestore() async {
    await FirebaseFirestore.instance.collection("history").doc("history_screen").set({
      "title": "History Screen",
      "topic": "Glo App History",
      "sections": historyItems.map((item) {
        return {
          "id": item["id"],
          "type": item["type"],
          "title": item["title"],
          "content": item["content"],
          "details": item["details"],
        };
      }).toList(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> _exportCycleData() async {
    final cycleData = {
      "lastPeriod": "3 June 2026",
      "duration": "5 days",
      "irregularity": "April shorter cycle",
    };

    final directory = await getApplicationDocumentsDirectory();

    final jsonFile = File('${directory.path}/cycle_data.json');
    await jsonFile.writeAsString(jsonEncode(cycleData));

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Cycle History",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Last Period: ${cycleData['lastPeriod']}"),
            pw.Text("Duration: ${cycleData['duration']}"),
            pw.Text("Irregularity: ${cycleData['irregularity']}"),
          ],
        ),
      ),
    );

    final pdfFile = File('${directory.path}/cycle_data.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(jsonFile.path), XFile(pdfFile.path)],
      text: 'Cycle Data Export',
    );
  }

  void _onBottomTap(int index) {
    if (index == 3) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/insights');
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CalendarScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GloProfileScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Screen not connected yet")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryScreen.softPink,
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        onTap: _onBottomTap,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withValues(alpha: 0.58),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
              child: Column(
                children: [
                  const TopNavigation(
                    isLoggedIn: true,
                    userName: "History",
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...historyItems.map(
                                (item) => _buildSection(
                              title: item["title"],
                              icon: item["icon"],
                              content: List<String>.from(item["content"]),
                              details: item["details"],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _exportButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<String> content,
    required String details,
  }) {
    return GestureDetector(
      onTap: () => _showDetailsDialog(title, details),
      child: _SoftCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _RoundIcon(icon: icon, iconSize: 29),
            const SizedBox(width: 14),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 260,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          fontFamily: "Georgia",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: HistoryScreen.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...content.map(
                            (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            item,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1,
                              color: HistoryScreen.dark,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: HistoryScreen.pink,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(String title, String details) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: HistoryScreen.softPink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: "Georgia",
            color: HistoryScreen.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          details,
          style: const TextStyle(
            color: HistoryScreen.dark,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: HistoryScreen.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportButton() {
    return GestureDetector(
      onTap: _exportCycleData,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F7).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HistoryScreen.borderPink),
          boxShadow: [
            BoxShadow(
              color: HistoryScreen.pink.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_download_outlined,
              color: HistoryScreen.pink,
              size: 26,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                "Export Cycle Data",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HistoryScreen.pink,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final double iconSize;

  const _RoundIcon({
    required this.icon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        color: HistoryScreen.iconBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        icon,
        color: HistoryScreen.pink,
        size: iconSize,
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const _SoftCard({
    required this.child,
    required this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: HistoryScreen.softPink.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HistoryScreen.borderPink),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}