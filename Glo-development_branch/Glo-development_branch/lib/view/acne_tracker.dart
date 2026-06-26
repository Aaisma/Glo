import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodel/user_view_model.dart';
import '../viewmodel/acne_tracker_viewmodel.dart';

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
    userId = FirebaseAuth.instance.currentUser?.uid ?? "demo_user"; // fallback only if no one's signed in
    final vm = context.read<AcneTrackerViewModel>();
    vm.loadToday(userId).then((_) {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AcneTrackerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Acne Tracker"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: vm.isLoading && vm.severity == "Unknown" && vm.imagePath.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
              // Current Skin & Acne Status (from survey/onboarding data)
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

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Current Skin & Acne Status",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text("Skin Type: $skinType", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text("Acne Concerns: $acneConcerns", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(
                            "Treatment: ${usesMedication ? '$medicationType ($medicationTime)' : 'None'}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Photo capture
              if (vm.imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(vm.imagePath, height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _showImageSourceSheet,
                icon: const Icon(Icons.camera_alt),
                label: Text(vm.imagePath.isEmpty ? "Add today's photo" : "Replace photo"),
              ),

              const SizedBox(height: 20),

              // Severity selector
              const Text("How's your skin today?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent)),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent)),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent)),
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
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _productController,
                      decoration: const InputDecoration(
                        hintText: "Enter product name...",
                      ),
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
                            color: starIndex < vm.products[index]["rating"]
                                ? Colors.amber
                                : Colors.grey,
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
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent)),
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
                  child: Text("✨ Stay confident, healing takes time! ✨",
                      textAlign: TextAlign.center),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                  await vm.saveToday(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Today's entry saved!")),
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
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}