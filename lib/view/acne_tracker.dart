import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/user_view_model.dart';
import '../viewmodel/acne_tracker_viewmodel.dart';
import '../app_colors.dart';

class AcneTrackerPage extends StatefulWidget {
  const AcneTrackerPage({super.key});

  @override
  State<AcneTrackerPage> createState() => _AcneTrackerPageState();
}

class _AcneTrackerPageState extends State<AcneTrackerPage> {
  final ImagePicker _picker = ImagePicker();
  late String userId;
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _checklistOptions = [
    "Washed Face Twice",
    "Applied Moisturizer",
    "Avoided Touching Face",
    "Stayed Hydrated",
  ];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? "demo_user";
    Future.microtask(() async {
      final vm = context.read<AcneTrackerViewModel>();
      await vm.initClassifier();
      await vm.loadToday(userId);
      _noteController.text = vm.note;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      await context.read<AcneTrackerViewModel>().uploadPhoto(File(image.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _scannerCorners() {
    const double size = 24;
    const double thickness = 3;
    BoxDecoration corner(bool top, bool left) => BoxDecoration(
      border: Border(
        top: top ? BorderSide(color: AppColors.pink, width: thickness) : BorderSide.none,
        bottom: !top ? BorderSide(color: AppColors.pink, width: thickness) : BorderSide.none,
        left: left ? BorderSide(color: AppColors.pink, width: thickness) : BorderSide.none,
        right: !left ? BorderSide(color: AppColors.pink, width: thickness) : BorderSide.none,
      ),
    );

    return [
      Positioned(top: 10, left: 10, child: Container(width: size, height: size, decoration: corner(true, true))),
      Positioned(top: 10, right: 10, child: Container(width: size, height: size, decoration: corner(true, false))),
      Positioned(bottom: 10, left: 10, child: Container(width: size, height: size, decoration: corner(false, true))),
      Positioned(bottom: 10, right: 10, child: Container(width: size, height: size, decoration: corner(false, false))),
    ];
  }

  Widget _statusRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.purple),
        const SizedBox(width: 8),
        Text("$label: ", style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.text)),
        Expanded(child: Text(value, style: TextStyle(color: AppColors.grey))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AcneTrackerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Acne Tracker"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skin scanner
              GestureDetector(
                onTap: vm.isLoading ? null : _showImageSourceSheet,
                child: Stack(
                  children: [
                    Container(
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: vm.imagePath.isNotEmpty
                          ? Image.network(vm.imagePath, fit: BoxFit.cover, width: double.infinity)
                          : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face_retouching_natural, size: 48, color: AppColors.pink),
                            const SizedBox(height: 10),
                            Text(
                              vm.isLoading ? "Scanning your skin..." : "Tap to scan your skin",
                              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (vm.isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                    ..._scannerCorners(),
                    if (vm.imagePath.isNotEmpty && !vm.isLoading)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: ElevatedButton.icon(
                          onPressed: _showImageSourceSheet,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text("Retake"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.pink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (vm.detectedType != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    "Detected: ${vm.detectedType} (${(vm.detectedConfidence! * 100).toStringAsFixed(0)}% confidence)",
                    style: TextStyle(color: AppColors.pink, fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 20),

              // Current Skin & Acne Status
              Consumer<UserViewModel>(
                builder: (context, userVM, child) {
                  final user = userVM.user;
                  final skinType = user?.skinType ?? "Normal";
                  final acneConcerns = user?.acneTypes != null && user!.acneTypes!.isNotEmpty
                      ? user.acneTypes!.join(", ")
                      : "None";
                  final usesMedication = user?.usesMedication ?? false;
                  final medicationType = user?.medicationType ?? "None";
                  final medicationTime = user?.medicationTime ?? "None";

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardPink,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderPink),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Skin & Acne Status",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.pink),
                        ),
                        const SizedBox(height: 14),
                        _statusRow(Icons.face_outlined, "Skin Type", skinType),
                        const SizedBox(height: 10),
                        _statusRow(Icons.healing_outlined, "Acne Concerns", acneConcerns),
                        const SizedBox(height: 10),
                        _statusRow(
                          Icons.medication_outlined,
                          "Treatment",
                          usesMedication ? "$medicationType ($medicationTime)" : "None",
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Severity selector
              const Text("How's your skin today?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ["Clear", "Mild", "Moderate", "Severe"].map((level) {
                  final selected = vm.severity == level;
                  return ChoiceChip(
                    label: Text(level),
                    selected: selected,
                    selectedColor: Colors.pinkAccent,
                    onSelected: (_) => vm.setSeverity(level),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Acne Types Gallery
              const Text("Acne Types",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  acneImageCard("Whiteheads", "assets/images/whiteheads.png"),
                  acneImageCard("Blackheads", "assets/images/blackheads.png"),
                  acneImageCard("Papules", "assets/images/papules.png"),
                  acneImageCard("Pustules", "assets/images/pustules.png"),
                  acneImageCard("Nodules", "assets/images/nodules.png"),
                  acneImageCard("Cystic Acne", "assets/images/cystic.png"),
                ],
              ),

              const SizedBox(height: 20),

              // Daily Care Checklist
              const Text("Daily Care Checklist",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              Column(
                children: _checklistOptions.map((task) {
                  return CheckboxListTile(
                    title: Text(task),
                    value: vm.checklist.contains(task),
                    activeColor: Colors.pinkAccent,
                    onChanged: (_) => vm.toggleChecklistItem(task),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Product Tracker with Star Rating
              const Text("Product Tracker",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _productController,
                      decoration: const InputDecoration(hintText: "Enter product name..."),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_productController.text.isNotEmpty) {
                        vm.addProduct(_productController.text);
                        _productController.clear();
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),
              Column(
                children: List.generate(vm.products.length, (index) {
                  return ListTile(
                    title: Text(vm.products[index]["name"]),
                    subtitle: Row(
                      children: List.generate(5, (starIndex) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: starIndex < vm.products[index]["rating"] ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () => vm.updateProductRating(index, starIndex + 1),
                        );
                      }),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => vm.removeProduct(index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Journal / Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Daily Journal",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(hintText: "Write your notes..."),
                        maxLines: 3,
                        onChanged: vm.updateNote,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Motivation Section
              Card(
                color: Colors.pink[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("✨ Stay confident, healing takes time! ✨", textAlign: TextAlign.center),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                  await vm.saveToday(userId);
                  if (context.mounted) {
                    final result = context.read<AcneTrackerViewModel>();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.errorMessage ?? "Today's entry saved!"),
                        backgroundColor: result.errorMessage != null ? Colors.red : null,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: vm.isLoading
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text("Save today's entry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget acneImageCard(String title, String assetPath) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black54,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}