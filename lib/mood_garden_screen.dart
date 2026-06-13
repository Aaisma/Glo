import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodGardenScreen extends StatefulWidget {
  const MoodGardenScreen({super.key});

  @override
  State<MoodGardenScreen> createState() => _MoodGardenScreenState();
}

class _MoodGardenScreenState extends State<MoodGardenScreen> {
  // Production App State metrics matching your design
  int totalEntries = 22;
  int plantsGrown = 5;
  int longestStreak = 7;

  // Level progression counters (Current Points / 10 Max)
  int sunflowerCount = 8;
  int roseCount = 4;
  int blueFlowerCount = 5;
  int cactusCount = 2;
  int droopingFlowerCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4), // Soft, organic off-white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Mood Garden',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // --- SECTION 1: THE FLOATING SHELF & REALISTIC FLOWER POTS ---
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Elegant Wooden Shelf Base
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCD8D53), // Authentic wooden shelf tone
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                      ),
                    ),

                    // Displaying the 5 beautiful vector flower pots side by side across the shelf line
                    Positioned(
                      bottom: 28,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // FIXED: Changed CrossAxisAlignment.bottom to CrossAxisAlignment.end to resolve the build error
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildGardenShelfPlant('rose', roseCount >= 10 ? 1.0 : 0.82),
                            _buildGardenShelfPlant('sunflower', sunflowerCount >= 10 ? 1.0 : 0.98),
                            _buildGardenShelfPlant('blue', blueFlowerCount >= 10 ? 1.0 : 0.88),
                            _buildGardenShelfPlant('cactus', cactusCount >= 10 ? 1.0 : 0.80),
                            _buildGardenShelfPlant('drooping', droopingFlowerCount >= 10 ? 1.0 : 0.78),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- SECTION 2: MOTIVATIONAL MOTTO & EMBEDDED LEAF ---
              const SizedBox(height: 20),
              const Text(
                'Your plants grow with your emotions.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2E3E33)),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Keep going! You\'re doing great ',
                    style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
                  ),
                  Text('🌱', style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 24),

              // --- SECTION 3: GARDEN METRIC STATS PANEL ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('🌿', '$totalEntries', 'Total Entries'),
                    Container(width: 1, height: 35, color: const Color(0xFFEFECE6)),
                    _buildStatColumn('🌱', '$plantsGrown', 'Plants Grown'),
                    Container(width: 1, height: 35, color: const Color(0xFFEFECE6)),
                    _buildStatColumn('💧', '$longestStreak', 'Longest Streak'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- SECTION 4: PLANT COLLECTION LEVEL LIST ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Plant Collection',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
                ),
              ),
              const SizedBox(height: 12),

              // Interactive level progression tiles
              _buildPlantProgressTile('Sunflower', 'Happy Days', 2, sunflowerCount, const Color(0xFFF9A825), 'sunflower'),
              _buildPlantProgressTile('Rose', 'Amazing Days', 1, roseCount, const Color(0xFFF06292), 'rose'),
              _buildPlantProgressTile('Blue Flower', 'Calm Days', 1, blueFlowerCount, const Color(0xFF42A5F5), 'blue'),
              _buildPlantProgressTile('Cactus', 'Angry Days', 1, cactusCount, const Color(0xFF66BB6A), 'cactus'),
              _buildPlantProgressTile('Drooping Flower', 'Sad Days', 1, droopingFlowerCount, const Color(0xFFAB47BC), 'drooping'),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String count, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPlantProgressTile(String title, String subtitle, int level, int count, Color progressColor, String type) {
    double progressFraction = count / 10.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          // Left side interactive flower preview asset
          GestureDetector(
            onTap: () {
              setState(() {
                if (type == 'sunflower') sunflowerCount = (sunflowerCount + 1) > 10 ? 1 : sunflowerCount + 1;
                if (type == 'rose') roseCount = (roseCount + 1) > 10 ? 1 : roseCount + 1;
                if (type == 'blue') blueFlowerCount = (blueFlowerCount + 1) > 10 ? 1 : blueFlowerCount + 1;
                if (type == 'cactus') cactusCount = (cactusCount + 1) > 10 ? 1 : cactusCount + 1;
                if (type == 'drooping') droopingFlowerCount = (droopingFlowerCount + 1) > 10 ? 1 : droopingFlowerCount + 1;
                totalEntries++;
              });
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: MiniFlowerPainter(type: type),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Center descriptive details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Lv. $level',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: progressColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          backgroundColor: const Color(0xFFF0EFEA),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right progress fraction labels
          Text(
            '$count/10',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenShelfPlant(String type, double scale) {
    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 65,
        height: 160,
        child: CustomPaint(
          painter: FullGardenPlantPainter(type: type),
        ),
      ),
    );
  }
}

// --- HIGHLY DETAILED VECTOR CANVAS GRAPHICS PAINTER ENGINE ---
class FullGardenPlantPainter extends CustomPainter {
  final String type;
  FullGardenPlantPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;
    final double cx = size.width / 2;
    final double bottomY = size.height;

    // 1. Draw Styled Organic Terracotta Clay Pots
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFE59364); // Warm earthy terracotta baseline

    Path potPath = Path();
    potPath.moveTo(cx - 15, bottomY - 2);
    potPath.lineTo(cx + 15, bottomY - 2);
    potPath.lineTo(cx + 19, bottomY - 28);
    potPath.lineTo(cx - 19, bottomY - 28);
    potPath.close();
    canvas.drawPath(potPath, paint);

    // Overhanging smooth rounded rim lip
    paint.color = const Color(0xFFDE8350);
    RRect potRim = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - 21, bottomY - 35, cx + 21, bottomY - 28),
      const Radius.circular(3),
    );
    canvas.drawRRect(potRim, paint);

    // 2. Structural Plant Stem Management
    double stemTopY = bottomY - 105;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    if (type == 'drooping') {
      paint.color = const Color(0xFF90C165);
      paint.strokeWidth = 3.5;
      Path droopingStem = Path();
      droopingStem.moveTo(cx, bottomY - 35);
      droopingStem.cubicTo(cx, bottomY - 85, cx + 28, bottomY - 135, cx + 22, bottomY - 95);
      canvas.drawPath(droopingStem, paint);
    } else if (type != 'cactus') {
      paint.color = const Color(0xFF9CCC65); // Vibrant plant green
      paint.strokeWidth = 3.0;
      canvas.drawLine(Offset(cx, bottomY - 35), Offset(cx, stemTopY), paint);

      // Add detailed structural leaves along sides
      paint.style = PaintingStyle.fill;
      Path leftLeaf = Path();
      leftLeaf.moveTo(cx, bottomY - 58);
      leftLeaf.quadraticBezierTo(cx - 16, bottomY - 72, cx - 5, bottomY - 80);
      leftLeaf.quadraticBezierTo(cx, bottomY - 68, cx, bottomY - 58);
      canvas.drawPath(leftLeaf, paint);

      Path rightLeaf = Path();
      rightLeaf.moveTo(cx, bottomY - 72);
      rightLeaf.quadraticBezierTo(cx + 16, bottomY - 86, cx + 5, bottomY - 94);
      rightLeaf.quadraticBezierTo(cx, bottomY - 82, cx, bottomY - 72);
      canvas.drawPath(rightLeaf, paint);
    }

    // 3. Render Botanical Flower Elements
    paint.style = PaintingStyle.fill;

    if (type == 'rose') {
      // Rose petal geometry
      double rx = cx;
      double ry = stemTopY;
      paint.color = const Color(0xFFF06292);
      canvas.drawCircle(Offset(rx, ry), 15, paint);

      paint.color = const Color(0xFFE91E63);
      Path innerPetal1 = Path()
        ..addOval(Rect.fromCircle(center: Offset(rx - 3, ry - 1), radius: 9));
      canvas.drawPath(innerPetal1, paint);

      paint.color = const Color(0xFFC2185B);
      canvas.drawCircle(Offset(rx + 2, ry + 2), 5, paint);
    }
    else if (type == 'sunflower') {
      // Golden Radiance Sunflower Petals
      double sx = cx;
      double sy = stemTopY - 5;
      paint.color = const Color(0xFFFFD54F);

      for (int i = 0; i < 12; i++) {
        double angle = (i * 30) * math.pi / 180;
        double px = sx + 14 * math.cos(angle);
        double py = sy + 14 * math.sin(angle);
        canvas.drawCircle(Offset(px, py), 6, paint);
      }

      canvas.drawCircle(Offset(sx, sy), 15, paint);
      paint.color = const Color(0xFF6D4C41); // Earthy central seed disk
      canvas.drawCircle(Offset(sx, sy), 10, paint);
    }
    else if (type == 'blue') {
      // 5-Petal Blue Calming Flower
      double bx = cx;
      double by = stemTopY;
      paint.color = const Color(0xFF42A5F5);

      for (int i = 0; i < 5; i++) {
        double angle = (i * 72) * math.pi / 180;
        double px = bx + 11 * math.cos(angle);
        double py = by + 11 * math.sin(angle);
        canvas.drawCircle(Offset(px, py), 8, paint);
      }
      // Golden central core
      paint.color = const Color(0xFFFFEE58);
      canvas.drawCircle(Offset(bx, by), 6, paint);
    }
    else if (type == 'cactus') {
      // Textured Oval Desert Cactus
      paint.color = const Color(0xFF66BB6A);
      Rect cactusRect = Rect.fromLTRB(cx - 13, bottomY - 92, cx + 13, bottomY - 35);
      canvas.drawRRect(RRect.fromRectAndRadius(cactusRect, const Radius.circular(12)), paint);

      // Top golden accent crown flower
      paint.color = const Color(0xFFFFB74D);
      canvas.drawCircle(Offset(cx, bottomY - 94), 5, paint);
    }
    else if (type == 'drooping') {
      // Elegant Weeping Bellflower
      double dx = cx + 22;
      double dy = bottomY - 92;
      paint.color = const Color(0xFFBA68C8);

      Path droopingBloom = Path();
      droopingBloom.moveTo(dx, dy - 5);
      droopingBloom.cubicTo(dx - 12, dy + 5, dx - 10, dy + 22, dx - 8, dy + 24);
      droopingBloom.lineTo(dx + 8, dy + 24);
      droopingBloom.cubicTo(dx + 10, dy + 22, dx + 12, dy + 5, dx, dy - 5);
      droopingBloom.close();
      canvas.drawPath(droopingBloom, paint);

      // Flared bottom edge details
      paint.color = const Color(0xFF9C27B0);
      canvas.drawCircle(Offset(dx - 4, dy + 24), 3, paint);
      canvas.drawCircle(Offset(dx + 4, dy + 24), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- MINI DISPATCH SYSTEM FOR THUMBNAILS ---
class MiniFlowerPainter extends CustomPainter {
  final String type;
  MiniFlowerPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;
    final double cx = size.width / 2;
    final double cy = size.height * 0.5;

    paint.style = PaintingStyle.fill;
    if (type == 'rose') {
      paint.color = const Color(0xFFF06292);
      canvas.drawCircle(Offset(cx, cy), 12, paint);
      paint.color = const Color(0xFFE91E63);
      canvas.drawCircle(Offset(cx, cy), 6, paint);
    } else if (type == 'sunflower') {
      paint.color = const Color(0xFFFFD54F);
      canvas.drawCircle(Offset(cx, cy), 12, paint);
      paint.color = const Color(0xFF6D4C41);
      canvas.drawCircle(Offset(cx, cy), 6, paint);
    } else if (type == 'blue') {
      paint.color = const Color(0xFF42A5F5);
      canvas.drawCircle(Offset(cx - 6, cy), 6, paint);
      canvas.drawCircle(Offset(cx + 6, cy), 6, paint);
      canvas.drawCircle(Offset(cx, cy - 6), 6, paint);
      canvas.drawCircle(Offset(cx, cy + 6), 6, paint);
      paint.color = const Color(0xFFFFEE58);
      canvas.drawCircle(Offset(cx, cy), 4, paint);
    } else if (type == 'cactus') {
      paint.color = const Color(0xFF66BB6A);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(cx - 8, cy - 11, cx + 8, cy + 11), const Radius.circular(6)), paint);
      paint.color = const Color(0xFFFFB74D);
      canvas.drawCircle(Offset(cx, cy - 12), 3, paint);
    } else if (type == 'drooping') {
      paint.color = const Color(0xFFBA68C8);
      canvas.drawCircle(Offset(cx, cy - 3), 9, paint);
      paint.color = const Color(0xFF9C27B0);
      canvas.drawCircle(Offset(cx, cy + 5), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
