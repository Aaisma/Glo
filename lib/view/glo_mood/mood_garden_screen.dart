import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodGardenScreen extends StatefulWidget {
  const MoodGardenScreen({super.key});

  @override
  State<MoodGardenScreen> createState() => _MoodGardenScreenState();
}

class _MoodGardenScreenState extends State<MoodGardenScreen> {
  // --- REAL-TIME APP STATE PERSISTENCE ---
  int totalEntries = 22;
  int plantsGrown = 5;
  int longestStreak = 7;

  // Level Progression XP State Trackers (Current XP / 10 Max)
  int sunflowerCount = 8;
  int roseCount = 4;
  int blueFlowerCount = 5;
  int cactusCount = 2;
  int droopingFlowerCount = 3;

  // Numerical Level Metrics
  int sunflowerLevel = 2;
  int roseLevel = 1;
  int blueFlowerLevel = 1;
  int cactusLevel = 1;
  int droopingFlowerLevel = 1;

  // Central Cultivation Trigger Event Handler
  void _cultivatePlant(String type) {
    setState(() {
      totalEntries++;
      switch (type) {
        case 'sunflower':
          if (sunflowerCount >= 10) {
            sunflowerCount = 1;
            sunflowerLevel++;
            plantsGrown++;
          } else {
            sunflowerCount++;
          }
          break;
        case 'rose':
          if (roseCount >= 10) {
            roseCount = 1;
            roseLevel++;
            plantsGrown++;
          } else {
            roseCount++;
          }
          break;
        case 'blue':
          if (blueFlowerCount >= 10) {
            blueFlowerCount = 1;
            blueFlowerLevel++;
            plantsGrown++;
          } else {
            blueFlowerCount++;
          }
          break;
        case 'cactus':
          if (cactusCount >= 10) {
            cactusCount = 1;
            cactusLevel++;
            plantsGrown++;
          } else {
            cactusCount++;
          }
          break;
        case 'drooping':
          if (droopingFlowerCount >= 10) {
            droopingFlowerCount = 1;
            droopingFlowerLevel++;
            plantsGrown++;
          } else {
            droopingFlowerCount++;
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final double availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomPadding;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Mood Garden',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. THE UNIFORM HEIGHT GARDEN SHELF SHOWCASE
              SizedBox(
                height: availableHeight * 0.28,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCA36D), Color(0xFFB97940)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildUniformShelfPlant('rose'),
                            _buildUniformShelfPlant('sunflower'),
                            _buildUniformShelfPlant('blue'),
                            _buildUniformShelfPlant('cactus'),
                            _buildUniformShelfPlant('drooping'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. MOTIVATIONAL SUBHEADINGS
              SizedBox(height: availableHeight * 0.02),
              const Text(
                'Your plants grow with your emotions.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2E3E33)),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Keep going! You\'re doing great ',
                    style: TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
                  ),
                  Text('🌱', style: TextStyle(fontSize: 12)),
                ],
              ),

              // 3. STATISTICAL SNAPSHOT PROFILE CARD
              SizedBox(height: availableHeight * 0.025),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('🌿', '$totalEntries', 'Total Entries'),
                    Container(width: 1, height: 28, color: const Color(0xFFEFECE6)),
                    _buildStatColumn('🌱', '$plantsGrown', 'Plants Grown'),
                    Container(width: 1, height: 28, color: const Color(0xFFEFECE6)),
                    _buildStatColumn('💧', '$longestStreak', 'Longest Streak'),
                  ],
                ),
              ),

              // 4. PLANT COLLECTION HEADLINE ANCHOR LABEL
              SizedBox(height: availableHeight * 0.025),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Plant Collection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
                ),
              ),

              // 5. THE ORIGINAL COLLECTION LIST TILES (INTERACTIVE & INTERCONNECTED)
              SizedBox(height: availableHeight * 0.01),
              Expanded(
                child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double segmentHeight = constraints.maxHeight / 5.4;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInteractivePlantTile('Sunflower', 'Happy Days', sunflowerLevel, sunflowerCount, const Color(0xFFFFA000), 'sunflower', segmentHeight),
                          _buildInteractivePlantTile('Rose', 'Amazing Days', roseLevel, roseCount, const Color(0xFFEC407A), 'rose', segmentHeight),
                          _buildInteractivePlantTile('Blue Flower', 'Calm Days', blueFlowerLevel, blueFlowerCount, const Color(0xFF1E88E5), 'blue', segmentHeight),
                          _buildInteractivePlantTile('Cactus', 'Angry Days', cactusLevel, cactusCount, const Color(0xFF4CAF50), 'cactus', segmentHeight),
                          _buildInteractivePlantTile('Drooping Flower', 'Sad Days', droopingFlowerLevel, droopingFlowerCount, const Color(0xFF8E24AA), 'drooping', segmentHeight),
                        ],
                      );
                    }
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          count,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildInteractivePlantTile(String title, String subtitle, int level, int count, Color progressColor, String type, double targetHeight) {
    double progressFraction = count / 10.0;

    return GestureDetector(
      onTap: () => _cultivatePlant(type),
      child: Container(
        height: targetHeight.clamp(48.0, 64.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: UnifiedGardenPlantPainter(type: type, isMiniature: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E3E33)),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        'Lv. $level',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: progressColor),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            backgroundColor: const Color(0xFFF0EFEA),
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$count/10',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniformShelfPlant(String type) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 0.48,
        child: CustomPaint(
          painter: UnifiedGardenPlantPainter(type: type, isMiniature: false),
        ),
      ),
    );
  }
}

// --- HIGH-FIDELITY UNIFORM-SCALE PLANT PAINTER ENGINE ---
class UnifiedGardenPlantPainter extends CustomPainter {
  final String type;
  final bool isMiniature;

  UnifiedGardenPlantPainter({required this.type, required this.isMiniature});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..isAntiAlias = true;
    final double cx = size.width / 2;
    final double bottomY = size.height;

    final double potScale = isMiniature ? 0.45 : 0.82;
    final double potWidthBase = 15 * potScale;
    final double potWidthTop = 19 * potScale;
    final double potHeight = 25 * potScale;
    final double potTopY = bottomY - potHeight;

    // 1. Terracotta Planter Pots
    paint.style = PaintingStyle.fill;
    Rect potRect = Rect.fromLTRB(cx - potWidthTop, potTopY, cx + potWidthTop, bottomY);
    paint.shader = const LinearGradient(
      colors: [Color(0xFFE99B6E), Color(0xFFD37B47), Color(0xFFB85E2A)],
      stops: [0.0, 0.6, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(potRect);

    Path potPath = Path();
    potPath.moveTo(cx - potWidthBase, bottomY - 1);
    potPath.lineTo(cx + potWidthBase, bottomY - 1);
    potPath.lineTo(cx + potWidthTop, potTopY);
    potPath.lineTo(cx - potWidthTop, potTopY);
    potPath.close();
    canvas.drawPath(potPath, paint);

    final double rimWidth = 22 * potScale;
    final double rimHeight = 6 * potScale;
    Rect rimRect = Rect.fromLTRB(cx - rimWidth, potTopY - rimHeight, cx + rimWidth, potTopY);
    paint.shader = const LinearGradient(
      colors: [Color(0xFFEEA67B), Color(0xFFC76D38)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rimRect);
    canvas.drawRRect(RRect.fromRectAndRadius(rimRect, Radius.circular(2 * potScale)), paint);
    paint.shader = null;

    // 2. Uniform Stem Structuring System
    double stemTopY = isMiniature ? (bottomY * 0.3) : (bottomY * 0.28);
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    if (type == 'drooping') {
      paint.color = const Color(0xFF7CB342);
      paint.strokeWidth = isMiniature ? 1.8 : 3.4;
      Path droopingStem = Path();
      droopingStem.moveTo(cx, potTopY - rimHeight);
      droopingStem.cubicTo(
        cx - 2, potTopY - (isMiniature ? 12 : 35),
        cx + (isMiniature ? 12 : 26), potTopY - (isMiniature ? 24 : 65),
        cx + (isMiniature ? 10 : 20), stemTopY + (isMiniature ? 6 : 14),
      );
      canvas.drawPath(droopingStem, paint);
    } else if (type != 'cactus') {
      paint.color = const Color(0xFF8BC34A);
      paint.strokeWidth = isMiniature ? 1.5 : 2.8;
      canvas.drawLine(Offset(cx, potTopY - rimHeight), Offset(cx, stemTopY), paint);

      paint.style = PaintingStyle.fill;
      double leafY1 = potTopY - (isMiniature ? 6 : 22);
      double leafY2 = potTopY - (isMiniature ? 14 : 42);

      // Left Leaf Curve
      Path leftLeaf = Path();
      leftLeaf.moveTo(cx, leafY1);
      leftLeaf.cubicTo(cx - (isMiniature ? 8 : 18), leafY1 - (isMiniature ? 3 : 8), cx - (isMiniature ? 10 : 20), leafY1 - (isMiniature ? 10 : 24), cx, leafY1 - (isMiniature ? 6 : 16));
      leftLeaf.close();
      paint.color = const Color(0xFF7CB342);
      canvas.drawPath(leftLeaf, paint);
      paint.color = const Color(0xFF9CCC65);
      Path leftLeafHi = Path();
      leftLeafHi.moveTo(cx, leafY1);
      leftLeafHi.cubicTo(cx - (isMiniature ? 4 : 9), leafY1 - (isMiniature ? 2 : 4), cx - (isMiniature ? 10 : 20), leafY1 - (isMiniature ? 10 : 24), cx, leafY1 - (isMiniature ? 6 : 16));
      leftLeafHi.close();
      canvas.drawPath(leftLeafHi, paint);

      // Right Leaf Curve
      Path rightLeaf = Path();
      rightLeaf.moveTo(cx, leafY2);
      rightLeaf.cubicTo(cx + (isMiniature ? 8 : 18), leafY2 - (isMiniature ? 3 : 8), cx + (isMiniature ? 10 : 20), leafY2 - (isMiniature ? 10 : 24), cx, leafY2 - (isMiniature ? 6 : 16));
      rightLeaf.close();
      paint.color = const Color(0xFF689F38);
      canvas.drawPath(rightLeaf, paint);
      paint.color = const Color(0xFF8BC34A);
      Path rightLeafHi = Path();
      rightLeafHi.moveTo(cx, leafY2);
      rightLeafHi.cubicTo(cx + (isMiniature ? 4 : 9), leafY2 - (isMiniature ? 2 : 4), cx + (isMiniature ? 10 : 20), leafY2 - (isMiniature ? 10 : 24), cx, leafY2 - (isMiniature ? 6 : 16));
      rightLeafHi.close();
      canvas.drawPath(rightLeafHi, paint);
    }

    // 3. Flower Petal Renderer
    paint.style = PaintingStyle.fill;

    if (type == 'rose') {
      double rx = cx;
      double ry = stemTopY;
      double radius = isMiniature ? 8 : 17;

      Rect roseBounds = Rect.fromCircle(center: Offset(rx, ry), radius: radius);
      paint.shader = RadialGradient(
        colors: const [Color(0xFFFA8072), Color(0xFFE91E63), Color(0xFF880E4F)],
        stops: const [0.2, 0.75, 1.0],
      ).createShader(roseBounds);
      canvas.drawCircle(Offset(rx, ry), radius, paint);
      paint.shader = null;

      paint.color = const Color(0xFFC2185B).withValues(alpha: 0.4);
      canvas.drawArc(roseBounds.deflate(radius * 0.3), 0, math.pi, true, paint);
      canvas.drawArc(roseBounds.deflate(radius * 0.5), math.pi, math.pi, true, paint);
      paint.color = const Color(0xFFFF80AB).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(rx, ry - (radius * 0.15)), radius * 0.25, paint);
    }
    else if (type == 'sunflower') {
      double sx = cx;
      double sy = stemTopY;
      double coreRadius = isMiniature ? 5 : 10;
      double petalLength = isMiniature ? 6 : 14;

      paint.color = const Color(0xFFFFCA28);
      int petalCount = isMiniature ? 10 : 16;
      for (int i = 0; i < petalCount; i++) {
        double angle = (i * (360 / petalCount)) * math.pi / 180;
        Path petalPath = Path();
        double tipX = sx + (coreRadius + petalLength) * math.cos(angle);
        double tipY = sy + (coreRadius + petalLength) * math.sin(angle);
        double sideX1 = sx + coreRadius * math.cos(angle - 0.2);
        double sideY1 = sy + coreRadius * math.sin(angle - 0.2);
        double sideX2 = sx + coreRadius * math.cos(angle + 0.2);
        double sideY2 = sy + coreRadius * math.sin(angle + 0.2);

        petalPath.moveTo(sideX1, sideY1);
        petalPath.quadraticBezierTo(
            sx + (coreRadius + petalLength * 0.5) * math.cos(angle + 0.1),
            sy + (coreRadius + petalLength * 0.5) * math.sin(angle + 0.1),
            tipX, tipY
        );
        petalPath.quadraticBezierTo(
            sx + (coreRadius + petalLength * 0.5) * math.cos(angle - 0.1),
            sy + (coreRadius + petalLength * 0.5) * math.sin(angle - 0.1),
            sideX2, sideY2
        );
        petalPath.close();

        paint.color = i % 2 == 0 ? const Color(0xFFFFB300) : const Color(0xFFFDD835);
        canvas.drawPath(petalPath, paint);
      }

      Rect coreBounds = Rect.fromCircle(center: Offset(sx, sy), radius: coreRadius);
      paint.shader = const RadialGradient(
        colors: [Color(0xFF3E2723), Color(0xFF5D4037), Color(0xFF8D6E63)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(coreBounds);
      canvas.drawCircle(Offset(sx, sy), coreRadius, paint);
      paint.shader = null;
    }
    else if (type == 'blue') {
      double bx = cx;
      double by = stemTopY;
      double petalRadius = isMiniature ? 5 : 9.5;

      int bluePetals = 5;
      for (int i = 0; i < bluePetals; i++) {
        double angle = (i * (360 / bluePetals)) * math.pi / 180;
        double px = bx + (petalRadius * 0.85) * math.cos(angle);
        double py = by + (petalRadius * 0.85) * math.sin(angle);

        Rect blueBounds = Rect.fromCircle(center: Offset(px, py), radius: petalRadius);
        paint.shader = const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
          begin: Alignment.center,
          end: Alignment.bottomRight,
        ).createShader(blueBounds);

        canvas.drawCircle(Offset(px, py), petalRadius, paint);
      }
      paint.shader = null;

      paint.color = const Color(0xFFFFF176);
      canvas.drawCircle(Offset(bx, by), petalRadius * 0.5, paint);
      paint.color = const Color(0xFFFBC02D);
      canvas.drawCircle(Offset(bx, by), petalRadius * 0.25, paint);
    }
    else if (type == 'cactus') {
      double cW = isMiniature ? 8 : 15;
      double cH = isMiniature ? 20 : 44;
      Rect cacRect = Rect.fromLTRB(cx - cW, potTopY - rimHeight - cH, cx + cW, potTopY - rimHeight);

      paint.shader = const LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF4CAF50), Color(0xFF2E7D32)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(cacRect);
      canvas.drawRRect(RRect.fromRectAndRadius(cacRect, Radius.circular(cW)), paint);
      paint.shader = null;

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 0.8;
      paint.color = const Color(0xFF388E3C).withValues(alpha: 0.4);
      canvas.drawLine(Offset(cx - (cW * 0.4), potTopY - rimHeight - cH + 3), Offset(cx - (cW * 0.4), potTopY - rimHeight - 1), paint);
      canvas.drawLine(Offset(cx + (cW * 0.4), potTopY - rimHeight - cH + 3), Offset(cx + (cW * 0.4), potTopY - rimHeight - 1), paint);

      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFFF7043);
      canvas.drawCircle(Offset(cx, potTopY - rimHeight - cH), isMiniature ? 2.5 : 5, paint);
      paint.color = const Color(0xFFFFCA28);
      canvas.drawCircle(Offset(cx, potTopY - rimHeight - cH), isMiniature ? 1.2 : 2.5, paint);
    }
    else if (type == 'drooping') {
      double dx = cx + (isMiniature ? 10 : 20);
      double dy = stemTopY + (isMiniature ? 6 : 14);
      double bloomSize = isMiniature ? 8 : 18;

      Rect dropBounds = Rect.fromLTRB(dx - bloomSize, dy, dx + bloomSize, dy + (bloomSize * 1.3));
      paint.shader = const LinearGradient(
        colors: [Color(0xFFE040FB), Color(0xFF9C27B0), Color(0xFF4A148C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(dropBounds);

      Path bellFlower = Path();
      bellFlower.moveTo(dx, dy);
      bellFlower.quadraticBezierTo(dx - bloomSize, dy + (bloomSize * 0.2), dx - bloomSize, dy + (bloomSize * 0.8));
      bellFlower.lineTo(dx - bloomSize, dy + (bloomSize * 1.2));
      bellFlower.lineTo(dx - (bloomSize * 0.4), dy + bloomSize);
      bellFlower.lineTo(dx, dy + (bloomSize * 1.3));
      bellFlower.lineTo(dx + (bloomSize * 0.4), dy + bloomSize);
      bellFlower.lineTo(dx + bloomSize, dy + (bloomSize * 1.2));
      bellFlower.quadraticBezierTo(dx + bloomSize, dy + (bloomSize * 0.2), dx, dy);
      bellFlower.close();
      canvas.drawPath(bellFlower, paint);
      paint.shader = null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}