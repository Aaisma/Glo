import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/user_viewmodel.dart';


import '../viewmodel/acne_tracker_viewmodel.dart';
import '../app_colors.dart';
import 'acne_details_page.dart';
import 'acne_history_screen.dart';

class AcneTrackerPage extends StatefulWidget {
  const AcneTrackerPage({super.key});

  @override
  State<AcneTrackerPage> createState() => _AcneTrackerPageState();
}

class _AcneTrackerPageState extends State<AcneTrackerPage>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _checklistOptions = [
    "Washed Face Twice",
    "Applied Moisturizer",
    "Avoided Touching Face",
    "Stayed Hydrated",
    "Cleaned Pillowcase",
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.98, end: 1.02).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    Future.microtask(() async {
      final vm = context.read<AcneTrackerViewModel>();
      await vm.initClassifier();
      if (vm.userId != null) {
        await vm.loadToday(vm.userId!);
        _noteController.text = vm.note;
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _productController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final vm = context.read<AcneTrackerViewModel>();
      await vm.uploadPhoto(File(image.path));
      if (vm.detectedType != null) {
        _showDetectionResult(vm.detectedType!, vm.detectedConfidence!);
      }
    }
  }

  void _showDetectionResult(String label, double confidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.lightPink, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: AppColors.pink, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("Skin Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Your skin analysis is ready!", style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 20),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.pink, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text("Confidence: ${(confidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: AppColors.pink.withOpacity(0.6), fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Text("This result has been automatically added to your daily tracker.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () => Navigator.pop(context),
              child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Fabulous!", style: TextStyle(color: Colors.white))),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(40))),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 30),
              const Text("Capture your Glow", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 10),
              const Text("Take a clear photo of your skin for analysis", style: TextStyle(color: AppColors.grey, fontSize: 14)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sourceButton(Icons.camera_rounded, "Camera", () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                  _sourceButton(Icons.photo_library_rounded, "Gallery", () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                ],
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sourceButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightPink,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.pink.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Icon(icon, color: AppColors.pink, size: 35),
          ),
          const SizedBox(height: 15),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AcneTrackerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Skin Tracker", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.pink,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcneHistoryScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── CUTE CAMERA SECTION ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: const BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: vm.isLoading ? null : _showImageSourceSheet,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) => Transform.scale(scale: vm.imagePath.isEmpty ? _pulseAnim.value : 1.0, child: child),
                      child: Container(
                        height: 240, width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 15))],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: vm.imagePath.isNotEmpty
                            ? (vm.imagePath.startsWith('http')
                            ? Image.network(vm.imagePath, fit: BoxFit.cover)
                            : Image.file(File(vm.imagePath), fit: BoxFit.cover))
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 90, height: 90,
                            decoration: const BoxDecoration(color: AppColors.lightPink, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_rounded, size: 45, color: AppColors.pink),
                          ),
                          const SizedBox(height: 20),
                          const Text("Tap to Scan Skin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.text)),
                          const SizedBox(height: 5),
                          Text("AI-powered acne detection", style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 13)),
                        ]),
                      ),
                    ),
                  ),
                  if (vm.detectedType != null)
                    Container(
                      margin: const EdgeInsets.only(top: 25),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text("Detection: ${vm.detectedType!.toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── SEVERITY ──
                  const Text("Today's Skin Status", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(children: ["Clear", "Mild", "Moderate", "Severe"].asMap().entries.map((entry) {
                    final level = entry.value;
                    final selected = vm.severity == level;
                    final colors = [AppColors.blue, AppColors.purple, AppColors.orange, AppColors.red];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => vm.setSeverity(level),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: selected ? colors[entry.key] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? colors[entry.key] : AppColors.borderPink),
                            boxShadow: selected ? [BoxShadow(color: colors[entry.key].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
                          ),
                          child: Text(level, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? Colors.white : AppColors.text)),
                        ),
                      ),
                    );
                  }).toList()),

                  const SizedBox(height: 35),

                  // ── ACNE TYPES ──
                  const Text("Illustrated Guide", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Learn how to identify and treat each type", style: TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _acneTypeCard(context, "Whiteheads", const Color(0xFFFFB74D), _WhiteheadPainter()),
                        _acneTypeCard(context, "Blackheads", const Color(0xFF9575CD), _BlackheadPainter()),
                        _acneTypeCard(context, "Papules", const Color(0xFFE91E63), _PapulePainter()),
                        _acneTypeCard(context, "Pustules", const Color(0xFF66BB6A), _PustulePainter()),
                        _acneTypeCard(context, "Nodules", const Color(0xFF42A5F5), _NodulePainter()),
                        _acneTypeCard(context, "Cystic", const Color(0xFFAB47BC), _CysticPainter()),
                        _acneTypeCard(context, "Milia", const Color(0xFFFFCCBC), _MiliaPainter()),
                        _acneTypeCard(context, "Fungal", const Color(0xFFD4E157), _FungalPainter()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ── CHECKLIST ──
                  const Text("Routine Checklist", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(color: AppColors.cardPink, borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.borderPink)),
                    child: Column(
                      children: _checklistOptions.map((task) {
                        final done = vm.checklist.contains(task);
                        return ListTile(
                          leading: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: done ? AppColors.pink : AppColors.grey),
                          title: Text(task, style: TextStyle(color: done ? AppColors.text : AppColors.grey, fontWeight: done ? FontWeight.bold : FontWeight.normal)),
                          onTap: () => vm.toggleChecklistItem(task),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ── JOURNAL ──
                  const Text("Reflections", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    onChanged: vm.updateNote,
                    decoration: InputDecoration(
                      hintText: "Diet, stress, sleep or period cycle triggers...",
                      filled: true,
                      fillColor: AppColors.cardPink,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: (vm.isLoading || vm.userId == null) ? null : () async {
                      await vm.saveToday(vm.userId!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(vm.errorMessage ?? "Your skin journey entry is saved! 🌸"),
                          backgroundColor: vm.errorMessage != null ? Colors.red : AppColors.pink,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      minimumSize: const Size.fromHeight(65),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 8,
                      shadowColor: AppColors.pink.withOpacity(0.4),
                    ),
                    child: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("COMMIT TO LOG 💖", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _acneTypeCard(BuildContext context, String title, Color color, CustomPainter painter) {
    final info = _getAcneInfo(title);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AcneDetailsPage(
        acneType: title,
        description: info.description,
        commonCauses: info.causes,
        treatmentTips: info.tips,
        illustration: CustomPaint(painter: painter),
      ))),
      child: Hero(
        tag: 'acne_$title',
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 60, height: 60, child: CustomPaint(painter: painter)),
            const SizedBox(height: 15),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ]),
        ),
      ),
    );
  }

  _AcneInfo _getAcneInfo(String type) {
    switch (type) {
      case "Whiteheads":
        return _AcneInfo("Closed pores trapped under the skin.", ["Excess Sebum", "Dead skin cells"], ["Salicylic Acid", "Gentle Cleansing"]);
      case "Blackheads":
        return _AcneInfo("Open pores oxidized by air.", ["Oily skin", "Large pores"], ["Exfoliation", "Double Cleanse"]);
      case "Papules":
        return _AcneInfo("Red, inflamed bumps without pus.", ["Bacteria", "Inflammation"], ["Benzoyl Peroxide", "Ice"]);
      case "Pustules":
        return _AcneInfo("Inflamed bumps with a white/yellow head.", ["Infection", "Clogged pores"], ["Spot treatment", "Hydrocolloid patches"]);
      case "Nodules":
        return _AcneInfo("Large, hard, painful bumps deep under skin.", ["Hormones", "Genetics"], ["See a Dermatologist", "Corticosteroids"]);
      case "Milia":
        return _AcneInfo("Tiny white keratin cysts.", ["Sun damage", "Harsh products"], ["Retinoids", "Professional extraction"]);
      case "Fungal":
        return _AcneInfo("Itchy, uniform small bumps (Malassezia folliculitis).", ["Sweat", "Humidity", "Antibiotics"], ["Ketoconazole", "Keep skin dry"]);
      default:
        return _AcneInfo("Deep, painful, pus-filled cysts.", ["Severe Hormonal imbalance", "Genetics"], ["Dermatologist advice", "Isotretinoin"]);
    }
  }
}

class _AcneInfo {
  final String description; final List<String> causes; final List<String> tips;
  _AcneInfo(this.description, this.causes, this.tips);
}

// ── CUSTOM PAINTERS (Drawing/Illustrated Style) ────────────────────────────

class _WhiteheadPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 24, Paint()..color = const Color(0xFFFFECB3));
    canvas.drawCircle(c, 14, Paint()..color = Colors.white);
    canvas.drawCircle(c.translate(-5, -5), 4, Paint()..color = Colors.white.withOpacity(0.5));
  }
  @override bool shouldRepaint(_) => false;
}

class _BlackheadPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 24, Paint()..color = const Color(0xFFE1BEE7));
    canvas.drawCircle(c, 10, Paint()..color = const Color(0xFF212121));
    canvas.drawCircle(c.translate(-3, -3), 3, Paint()..color = Colors.white24);
  }
  @override bool shouldRepaint(_) => false;
}

class _PapulePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 5);
    canvas.drawCircle(c, 25, Paint()..color = const Color(0xFFFFCDD2));
    canvas.drawCircle(c.translate(0, -5), 15, Paint()..color = const Color(0xFFEF5350));
  }
  @override bool shouldRepaint(_) => false;
}

class _PustulePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 5);
    canvas.drawCircle(c, 25, Paint()..color = const Color(0xFFC8E6C9));
    canvas.drawCircle(c.translate(0, -5), 15, Paint()..color = const Color(0xFFEF5350));
    canvas.drawCircle(c.translate(0, -8), 8, Paint()..color = const Color(0xFFFFF9C4));
  }
  @override bool shouldRepaint(_) => false;
}

class _NodulePainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 28, Paint()..color = const Color(0xFFBBDEFB));
    canvas.drawCircle(c, 18, Paint()..color = const Color(0xFF1E88E5));
  }
  @override bool shouldRepaint(_) => false;
}

class _CysticPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(c, 28, Paint()..color = const Color(0xFFF3E5F5));
    canvas.drawCircle(c, 20, Paint()..color = const Color(0xFFAB47BC));
    canvas.drawCircle(c.translate(0, 3), 10, Paint()..color = const Color(0xFF4A148C).withOpacity(0.5));
  }
  @override bool shouldRepaint(_) => false;
}

class _MiliaPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(c.translate(i * 10.0 - 10, i % 2 == 0 ? 5 : -5), 6, Paint()..color = Colors.white);
      canvas.drawCircle(c.translate(i * 10.0 - 10, i % 2 == 0 ? 5 : -5), 7, Paint()..color = AppColors.borderPink..style = PaintingStyle.stroke);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _FungalPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(c.translate((i % 3) * 12.0 - 12, (i / 3) * 12.0 - 6), 5, Paint()..color = const Color(0xFFFFAB91));
    }
  }
  @override bool shouldRepaint(_) => false;
}