import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../viewmodel/acne_viewmodel.dart';
import '../services/acne_service.dart';

class AcneTrackerPage extends StatefulWidget {
  const AcneTrackerPage({super.key});

  @override
  State<AcneTrackerPage> createState() => _AcneTrackerPageState();
}

class _AcneTrackerPageState extends State<AcneTrackerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  late AcneViewModel vm;

  final TextEditingController _productController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final Map<String, bool> _checklist = {
    "Washed Face Twice": false,
    "Applied Moisturizer": false,
    "Avoided Touching Face": false,
    "Stayed Hydrated": false,
  };

  @override
  void initState() {
    super.initState();

    // ✅ CONNECT VIEWMODEL + SERVICE
    vm = AcneViewModel(
      AcneService(uid: "demo_user"), // replace with FirebaseAuth later
    );
  }

  // 📸 CAMERA PICK
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      vm.updateImage(image.path);
    }
  }

  // ➕ ADD PRODUCT
  void _addProduct() {
    if (_productController.text.isNotEmpty) {
      setState(() {
        vm.addProduct(_productController.text);
        _productController.clear();
      });
    }
  }

  // 💾 SAVE TO FIREBASE
  Future<void> _save() async {
    await vm.saveToday();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acne Tracker"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📊 STATUS
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Current Acne Status",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("Severity: Moderate"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📸 CAMERA
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Upload a Photo"),
            ),

            if (_selectedImage != null)
              Image.file(
                File(_selectedImage!.path),
                height: 200,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 20),

            // ☑️ CHECKLIST
            const Text(
              "Daily Care Checklist",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),

            Column(
              children: _checklist.keys.map((task) {
                return CheckboxListTile(
                  title: Text(task),
                  value: _checklist[task],
                  activeColor: Colors.pinkAccent,
                  onChanged: (val) {
                    setState(() {
                      _checklist[task] = val ?? false;
                      vm.toggleChecklist(task, val ?? false);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 🧴 PRODUCT INPUT
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      hintText: "Enter product...",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addProduct,
                  child: const Text("Add"),
                )
              ],
            ),

            const SizedBox(height: 20),

            // 📝 NOTE
            TextField(
              controller: _noteController,
              onChanged: vm.updateNote,
              decoration: const InputDecoration(
                hintText: "Write notes...",
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // 💾 SAVE BUTTON
            ElevatedButton(
              onPressed: _save,
              child: const Text("Save Today"),
            ),
          ],
        ),
      ),
    );
  }
}