import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:glo/model/health_model.dart';
import 'package:glo/viewmodel/health_viewmodel.dart';

class TreatmentTrackerScreen extends StatefulWidget {
  final String userId;

  const TreatmentTrackerScreen({
    super.key,
    this.userId = "test-user-001",
  });

  @override
  State<TreatmentTrackerScreen> createState() => _TreatmentTrackerScreenState();
}

class _TreatmentTrackerScreenState extends State<TreatmentTrackerScreen> {
  static const Color _pink = Color(0xFFFF7DA4);
  static const Color _dark = Color(0xFF24303F);
  static const Color _softPink = Color(0xFFFFEFF4);
  static const Color _pageBg = Color(0xFFFFF7F9);

  final ImagePicker _picker = ImagePicker();

  File? _photo;
  double _progress = .45;
  bool _isSaving = false;

  final List<TreatmentLog> _defaultLogs = const [
    TreatmentLog(
      date: "April 24, 2026",
      title: "Sunscreen",
      subtitle: "Morning Routine",
      icon: Icons.wb_sunny_outlined,
    ),
    TreatmentLog(
      date: "April 23, 2026",
      title: "Serum",
      subtitle: "Evening Routine",
      icon: Icons.water_drop_outlined,
    ),
  ];

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (!mounted || image == null) return;
    setState(() => _photo = File(image.path));
  }

  void _showPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _bottomSheet(
        children: [
          if (_photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _photo!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _primaryButton(
                  "Camera",
                  Icons.camera_alt_outlined,
                      () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _primaryButton(
                  "Gallery",
                  Icons.photo_outlined,
                      () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          if (_photo != null)
            TextButton.icon(
              onPressed: () {
                setState(() => _photo = null);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_outline, color: _pink),
              label: const Text(
                "Delete Photo",
                style: TextStyle(color: _pink),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddTreatmentSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _bottomSheet(
          children: [
            const Text(
              "Add Treatment 🌸",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _dark,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: _inputDecoration("Treatment name"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _primaryButton(
                _isSaving ? "Saving..." : "Save",
                Icons.check,
                _isSaving
                    ? () {}
                    : () async {
                  final value = controller.text.trim();

                  if (value.isEmpty) return;

                  await _saveTreatment(value);

                  if (!mounted) return;

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  Future<void> _saveTreatment(String treatmentName) async {
    final messenger = ScaffoldMessenger.of(context);
    final viewModel = context.read<HealthViewModel>();

    if (widget.userId.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("User ID is required.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newProgress = ((_progress + .08) * 100).round().clamp(0, 100);

    final item = HealthModel(
      userId: widget.userId,
      title: "Treatment Tracker",
      description: "New Routine",
      treatmentName: treatmentName,
      progress: newProgress,
      startDate: DateTime.now(),
    );

    try {
      await viewModel.addHealthItem(
        item,
        widget.userId,
      );

      if (!mounted) return;

      if (viewModel.error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(viewModel.error!)),
        );
        return;
      }

      setState(() {
        _progress = (_progress + .08).clamp(0, 1);
      });

      messenger.showSnackBar(
        const SnackBar(content: Text("Treatment saved successfully 🌸")),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text("Failed to save treatment: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showLogDetail(TreatmentLog log) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _pageBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBox(log.icon),
              const SizedBox(height: 12),
              Text(
                log.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 4),
              Text(log.date, style: const TextStyle(color: _pink)),
              const SizedBox(height: 6),
              Text(log.subtitle),
              const SizedBox(height: 18),
              _primaryButton(
                "Close",
                Icons.close,
                    () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TreatmentLog> _convertHealthItemsToLogs(List<HealthModel> items) {
    return items
        .where((item) =>
    item.treatmentName != null &&
        item.treatmentName!.trim().isNotEmpty)
        .map(
          (item) => TreatmentLog(
        date: _formatDate(item.startDate ?? item.createdAt),
        title: item.treatmentName ?? "Treatment",
        subtitle: item.description ?? "Treatment Routine",
        icon: Icons.spa_outlined,
      ),
    )
        .toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Today";

    final localDate = date.toLocal();

    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${months[localDate.month - 1]} ${localDate.day}, ${localDate.year}";
  }

  @override
  Widget build(BuildContext context) {
    final healthViewModel = context.watch<HealthViewModel>();

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBackButton(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 105),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Treatment Tracker",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                  fontFamily: 'Serif',
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Track your treatment progress\nand glow with confidence ♡",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _progressCard(),
                              const SizedBox(height: 18),
                              _photoCard(),
                              const SizedBox(height: 25),
                              const Text(
                                "Treatment Logs",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _dark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              StreamBuilder<List<HealthModel>>(
                                stream: healthViewModel.fetchHealthItemsStream(
                                  widget.userId,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator(
                                          color: _pink,
                                        ),
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return _emptyMessage(
                                      "Error loading treatments",
                                    );
                                  }

                                  final firestoreLogs =
                                  _convertHealthItemsToLogs(
                                    snapshot.data ?? [],
                                  );

                                  final logs = firestoreLogs.isEmpty
                                      ? _defaultLogs
                                      : firestoreLogs;

                                  return Column(
                                    children: logs.map(_logTile).toList(),
                                  );
                                },
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 25,
                          child: _addButton(),
                        ),
                      ],
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

  Widget _emptyMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _topBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _circleButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: _pink, size: 18),
        onPressed: onTap,
      ),
    );
  }

  Widget _progressCard() {
    return _glassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _progressCircle(),
          const SizedBox(width: 18),
          Container(
            width: 1,
            height: 78,
            color: _pink.withValues(alpha: .13),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You’re doing amazing!",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                  color: _pink,
                  backgroundColor: _pink.withValues(alpha: .14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressCircle() {
    return SizedBox(
      height: 82,
      width: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: _pink,
              backgroundColor: _pink.withValues(alpha: .16),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${(_progress * 100).round()}%",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _pink,
                  height: .9,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Complete",
                style: TextStyle(
                  fontSize: 10,
                  color: _dark,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoCard() {
    return InkWell(
      onTap: _showPhotoSheet,
      borderRadius: BorderRadius.circular(24),
      child: _glassCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _iconBox(Icons.camera_alt_outlined),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Track Your Skin",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Add a photo to see your progress over time.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (_photo == null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: _pink,
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _photo!,
                  height: 58,
                  width: 58,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _logTile(TreatmentLog log) {
    return GestureDetector(
      onTap: () => _showLogDetail(log),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _iconBox(log.icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    log.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              log.date,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _pink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: InkWell(
        onTap: _showAddTreatmentSheet,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF97B8), _pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "+ Add Treatment",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: _softPink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: _pink, size: 30),
    );
  }

  Widget _primaryButton(String text, IconData icon, VoidCallback onTap) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: FilledButton.styleFrom(
        backgroundColor: _pink,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
    );
  }

  Widget _bottomSheet({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: _pageBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: _softPink,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: child,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.pink.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class TreatmentLog {
  final String date;
  final String title;
  final String subtitle;
  final IconData icon;

  const TreatmentLog({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}