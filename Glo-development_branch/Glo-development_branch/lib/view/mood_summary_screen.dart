import  'package:flutter/material.dart';
import 'dart:math' as math;

class MoodSummaryScreen extends StatefulWidget {
  const MoodSummaryScreen({super.key});

  @override
  State<MoodSummaryScreen> createState() => _MoodSummaryScreenState();
}

class _MoodSummaryScreenState extends State<MoodSummaryScreen> {
  String selectedTimeframe = "This Week";

  final List<Map<String, dynamic>> moodSummaryData = [
    {'name': 'Amazing', 'emoji': '🤩', 'count': 2, 'percent': 14, 'color': const Color(0xFFFF6584)},
    {'name': 'Happy', 'emoji': '😀', 'count': 5, 'percent': 36, 'color': const Color(0xFFFFCE56)},
    {'name': 'Calm', 'emoji': '😌', 'count': 3, 'percent': 21, 'color': const Color(0xFF36A2EB)},
    {'name': 'Neutral', 'emoji': '😐', 'count': 2, 'percent': 14, 'color': const Color(0xFFA0A0A0)},
    {'name': 'Sad', 'emoji': '😢', 'count': 1, 'percent': 7, 'color': const Color(0xFF9966FF)},
    {'name': 'Angry', 'emoji': '😡', 'count': 1, 'percent': 7, 'color': const Color(0xFFFF9F40)},
  ];

  final List<Map<String, dynamic>> dailyJourney = [
    {'day': 'Mon', 'val': 0.60, 'emoji': '😀'},
    {'day': 'Tue', 'val': 0.30, 'emoji': '😢'},
    {'day': 'Wed', 'val': 0.60, 'emoji': '😀'},
    {'day': 'Thu', 'val': 0.40, 'emoji': '😐'},
    {'day': 'Fri', 'val': 0.70, 'emoji': '🤩'},
    {'day': 'Sat', 'val': 0.85, 'emoji': '🤩'},
    {'day': 'Sun', 'val': 0.45, 'emoji': '😌'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Mood Summary',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxHeight = constraints.maxHeight;
            final double internalPadding = maxHeight * 0.015;
            final double headerFontSize = maxHeight * 0.021;
            final double textFontSize = maxHeight * 0.015;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. TIMEFRAME SELECTOR ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                  SizedBox(height: internalPadding),

                  // --- 2. CARD 1: YOUR MOOD SUMMARY ---
                  Expanded(
                    flex: 35,
                    child: Container(
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
                          Text(
                            'Your Mood Summary',
                            style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Text(
                            'Overview of your emotions this week.',
                            style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                flex: 40,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: Size.infinite,
                                        painter: DonutChartPainter(data: moodSummaryData),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle, //  Moved inside BoxDecoration
                                          color: Color(0xFFF2EAFF), //  Moved inside BoxDecoration
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        child: const Text('💜', style: TextStyle(fontSize: 20)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 60,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: moodSummaryData.map((item) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        children: [
                                          Text(item['emoji'], style: const TextStyle(fontSize: 13)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item['name'],
                                              style: TextStyle(fontSize: textFontSize, fontWeight: FontWeight.w600, color: Colors.black87),
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
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2FE),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Text('✨', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                  ),
                  SizedBox(height: internalPadding),

                  // --- 3. CARD 2: YOUR MOOD JOURNEY GRAPH ---
                  Expanded(
                    flex: 26,
                    child: Container(
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
                          Text(
                            'Your Mood Journey',
                            style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const Text(
                            'A look at your day',
                            style: TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 80,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double w = constraints.maxWidth;
                                final double h = constraints.maxHeight;
                                const double paddingBottom = 16.0;
                                final double chartHeight = h - 36.0;
                                final double stepX = w / (dailyJourney.length - 1);

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: JourneyCurvePainter(journeyData: dailyJourney),
                                      ),
                                    ),
                                    ...List.generate(dailyJourney.length, (index) {
                                      final item = dailyJourney[index];
                                      final double leftPos = index * stepX;
                                      final double topPos = h - paddingBottom - (item['val'] * chartHeight) - 10;
                                      return Positioned(
                                        left: leftPos - 11,
                                        top: topPos,
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(15),
                                                blurRadius: 3,
                                              )
                                            ],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(item['emoji'], style: const TextStyle(fontSize: 12)),
                                        ),
                                      );
                                    }),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: dailyJourney.map((item) {
                                          return SizedBox(
                                            width: w / dailyJourney.length,
                                            child: Text(
                                              item['day'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: internalPadding),

                  // --- 4. THIS WEEK IN A NUTSHELL ---
                  Text(
                    'This Week in a Nutshell',
                    style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFixedNutshellCard('😊', '14', 'Total Logs'),
                        _buildFixedNutshellCard('⭐', '8', 'Positive'),
                        _buildFixedNutshellCard('🌿', '3', 'Calm Days'),
                        _buildFixedNutshellCard('💜', '2', 'Self-care'),
                      ],
                    ),
                  ),
                  SizedBox(height: internalPadding),

                  // --- 5. BOTTOM INSIGHT BANNER ---
                  Expanded(
                    flex: 12,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEFE8FC), Color(0xFFE4DAFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('“', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A4BBD), height: 0.5)),
                          Text(
                            'You\'re allowed to be both a masterpiece and a work in progress.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A3485),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text('💜', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFixedNutshellCard(String icon, String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2EFF6), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
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

class DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..isAntiAlias = true;

    final double radius = (math.min(size.width, size.height) / 2) - 10;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (var item in data) {
      final double sweepAngle = ((item['percent'] ?? 0) / 100) * (2 * math.pi);
      paint.color = item['color'];
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JourneyCurvePainter extends CustomPainter {
  final List<Map<String, dynamic>> journeyData;
  JourneyCurvePainter({required this.journeyData});

  @override
  void paint(Canvas canvas, Size size) {
    if (journeyData.isEmpty) return;

    final double w = size.width;
    final double h = size.height;
    const double paddingBottom = 16.0;
    final double chartHeight = h - 40.0;
    final double stepX = w / (journeyData.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < journeyData.length; i++) {
      double x = i * stepX;
      double y = h - paddingBottom - (journeyData[i]['val'] * chartHeight);
      points.add(Offset(x, y));
    }

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
        const Color(0xFFFF6584).withAlpha(51),
        const Color(0xFFFFCE56).withAlpha(25),
        const Color(0xFF36A2EB).withAlpha(2),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTRB(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

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