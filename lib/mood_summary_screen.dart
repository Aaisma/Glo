import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodSummaryScreen extends StatefulWidget {
  const MoodSummaryScreen({super.key});

  @override
  State<MoodSummaryScreen> createState() => _MoodSummaryScreenState();
}

class _MoodSummaryScreenState extends State<MoodSummaryScreen> {
  String selectedTimeframe = "This Week";

  // Data map matching your precise reference counts & distributions
  final List<Map<String, dynamic>> moodSummaryData = [
    {'name': 'Amazing', 'emoji': '🤩', 'count': 2, 'percent': 14, 'color': const Color(0xFFFF6584)},
    {'name': 'Happy', 'emoji': '😀', 'count': 5, 'percent': 36, 'color': const Color(0xFFFFCE56)},
    {'name': 'Calm', 'emoji': '😌', 'count': 3, 'percent': 21, 'color': const Color(0xFF36A2EB)},
    {'name': 'Neutral', 'emoji': '😐', 'count': 2, 'percent': 14, 'color': const Color(0xFFA0A0A0)},
    {'name': 'Sad', 'emoji': '😢', 'count': 1, 'percent': 7, 'color': const Color(0xFF9966FF)},
    {'name': 'Angry', 'emoji': '😡', 'count': 1, 'percent': 7, 'color': const Color(0xFFFF9F40)},
  ];

  // Daily points mapping for the Mood Journey curve chart
  final List<Map<String, dynamic>> dailyJourney = [
    {'day': 'Mon', 'val': 0.60, 'emoji': '😀', 'color': const Color(0xFFFFCE56)},
    {'day': 'Tue', 'val': 0.30, 'emoji': '😢', 'color': const Color(0xFF9966FF)},
    {'day': 'Wed', 'val': 0.60, 'emoji': '😀', 'color': const Color(0xFFFFCE56)},
    {'day': 'Thu', 'val': 0.40, 'emoji': '😐', 'color': const Color(0xFFA0A0A0)},
    {'day': 'Fri', 'val': 0.70, 'emoji': '🤩', 'color': const Color(0xFFFF6584)},
    {'day': 'Sat', 'val': 0.85, 'emoji': '🤩', 'color': const Color(0xFFFF6584)},
    {'day': 'Sun', 'val': 0.45, 'emoji': '😌', 'color': const Color(0xFF36A2EB)},
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // Strict mathematical available space definition to completely stop scrolling
    final double availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomPadding;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FC), // Exact soft background tone
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Mood Summary',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. TIMEFRAME SELECTOR CHIP (Allocated 5% height) ---
              SizedBox(
                height: availableHeight * 0.05,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1EBF9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF6A4BBD), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          selectedTimeframe,
                          style: const TextStyle(color: Color(0xFF6A4BBD), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6A4BBD), size: 14),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: availableHeight * 0.015),

              // --- 2. CARD 1: YOUR MOOD SUMMARY (Allocated 32% height) ---
              Container(
                height: availableHeight * 0.32,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF2EFF6), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Mood Summary',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text(
                      'Overview of your emotions this week.',
                      style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox(height: 4)),
                    Row(
                      children: [
                        // Dynamic Donut Chart Area
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(100, 100),
                                painter: DonutChartPainter(data: moodSummaryData),
                              ),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF2EAFF),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text('💜', style: TextStyle(fontSize: 20)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Side Metrics Grid
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: moodSummaryData.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    Text(item['emoji'], style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      "${item['count']} (${item['percent']}%)",
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox(height: 4)),
                    // Insight message footer bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F2FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'You felt happy most of the time this week!',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  'Keep doing what makes you feel good.',
                                  style: TextStyle(fontSize: 10, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: availableHeight * 0.02),

              // --- 3. CARD 2: YOUR MOOD JOURNEY GRAPH (Allocated 25% height) ---
              Container(
                height: availableHeight * 0.25,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF2EFF6), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Mood Journey',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text(
                      'A look at your day',
                      style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                    ),
                    const Expanded(child: SizedBox(height: 4)),
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: JourneyCurvePainter(journeyData: dailyJourney),
                            ),
                          ),
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double w = constraints.maxWidth;
                                final double h = constraints.maxHeight;
                                final double stepX = w / (dailyJourney.length - 1);
                                return Stack(
                                  children: List.generate(dailyJourney.length, (index) {
                                    final item = dailyJourney[index];
                                    final double leftPos = index * stepX;
                                    final double topPos = h - (item['val'] * (h - 45)) - 32;
                                    return Positioned(
                                      left: leftPos - 10,
                                      top: topPos.clamp(0.0, h - 40),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(item['emoji'], style: const TextStyle(fontSize: 12)),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double stepX = constraints.maxWidth / (dailyJourney.length - 1);
                                return Stack(
                                  children: List.generate(dailyJourney.length, (index) {
                                    return Positioned(
                                      left: index * stepX - 10,
                                      child: SizedBox(
                                        width: 20,
                                        child: Text(
                                          dailyJourney[index]['day'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: availableHeight * 0.02),

              // --- 4. THIS WEEK IN A NUTSHELL AREA (Allocated 16% height) ---
              const Text(
                'This Week in a Nutshell',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: availableHeight * 0.008),
              SizedBox(
                height: availableHeight * 0.11,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFixedNutshellCard('😊', '14', 'Total Logs'),
                    _buildFixedNutshellCard('⭐', '8', 'Positive Days'),
                    _buildFixedNutshellCard('🌿', '3', 'Calm Days'),
                    _buildFixedNutshellCard('💜', '2', 'Self-care Days'),
                  ],
                ),
              ),
              SizedBox(height: availableHeight * 0.02),

              // --- 5. BOTTOM INSIGHT QUOTE CARD (Allocated 13% height) ---
              Container(
                height: availableHeight * 0.13,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEFE8FC), Color(0xFFE4DAFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('“', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A4BBD), height: 0.5)),
                    Text(
                      'You\'re allowed to be both\na masterpiece and a work in progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A3485),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text('💜', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedNutshellCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2EFF6), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Colors.black45, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// --- VECTOR DONUT CANVAS GENERATOR ---
class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..isAntiAlias = true;

    final Rect rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    double startAngle = -math.pi / 2;

    for (var item in data) {
      final double sweepAngle = (item['percent'] / 100) * (2 * math.pi);
      paint.color = item['color'];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- JOURNEY SMOOTH VECTOR GRAPH WAVE PAINTER ---
class JourneyCurvePainter extends CustomPainter {
  final List<Map<String, dynamic>> journeyData;
  JourneyCurvePainter({required this.journeyData});

  @override
  void paint(Canvas canvas, Size size) {
    if (journeyData.isEmpty) return;

    final double w = size.width;
    final double h = size.height;
    final double paddingBottom = 20.0;
    final double chartHeight = h - 45.0;
    final double stepX = w / (journeyData.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < journeyData.length; i++) {
      double x = i * stepX;
      double y = h - paddingBottom - (journeyData[i]['val'] * chartHeight);
      points.add(Offset(x, y));
    }

    // Gradient Wave Background Shading
    Path fillPath = Path();
    fillPath.moveTo(points.first.dx, h - paddingBottom);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      var p0 = points[i];
      var p1 = points[i + 1];
      fillPath.cubicTo(
        p0.dx + (stepX / 2), p0.dy,
        p1.dx - (stepX / 2), p1.dy,
        p1.dx, p1.dy,
      );
    }
    fillPath.lineTo(points.last.dx, h - paddingBottom);
    fillPath.close();

    Paint fillPaint = Paint()..style = PaintingStyle.fill;
    fillPaint.shader = LinearGradient(
      colors: [
        const Color(0xFFFF6584).withValues(alpha: 0.2),
        const Color(0xFFFFCE56).withValues(alpha: 0.1),
        const Color(0xFF36A2EB).withValues(alpha: 0.01),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTRB(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Primary Colored Flow Line Stroke
    Path strokePath = Path();
    strokePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      var p0 = points[i];
      var p1 = points[i + 1];
      strokePath.cubicTo(
        p0.dx + (stepX / 2), p0.dy,
        p1.dx - (stepX / 2), p1.dy,
        p1.dx, p1.dy,
      );
    }

    Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    strokePaint.shader = const LinearGradient(
      colors: [
        Color(0xFFFFCE56),
        Color(0xFF9966FF),
        Color(0xFFFFCE56),
        Color(0xFFA0A0A0),
        Color(0xFFFF6584),
        Color(0xFF36A2EB),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTRB(0, 0, w, h));

    canvas.drawPath(strokePath, strokePaint);

    // Clean Dashed drop guidelines
    Paint linePaint = Paint()
      ..color = const Color(0xFFE2DFE8)
      ..strokeWidth = 0.8;

    for (var pt in points) {
      double startY = pt.dy + 12;
      double endY = h - paddingBottom;
      while (startY < endY) {
        canvas.drawLine(Offset(pt.dx, startY), Offset(pt.dx, (startY + 3).clamp(startY, endY)), linePaint);
        startY += 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}