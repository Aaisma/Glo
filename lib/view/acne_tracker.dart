import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AcneTrackerPage extends StatefulWidget {
  const AcneTrackerPage({super.key});

  @override
  State<AcneTrackerPage> createState() => _AcneTrackerPageState();
}

class _AcneTrackerPageState extends State<AcneTrackerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  final Map<String, bool> _checklist = {
    "Washed Face Twice": false,
    "Applied Moisturizer": false,
    "Avoided Touching Face": false,
    "Stayed Hydrated": false,
  };

  final List<Map<String, dynamic>> _products = [];
  final TextEditingController _productController = TextEditingController();

  void _addProduct() {
    if (_productController.text.isNotEmpty) {
      setState(() {
        _products.add({"name": _productController.text, "rating": 0});
        _productController.clear();
      });
    }
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _updateRating(int index, int rating) {
    setState(() {
      _products[index]["rating"] = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Current Acne Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      Text("Current Acne Status",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent)),
                      SizedBox(height: 8),
                      Text("Severity: Moderate"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload Photo
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Upload a Photo"),
              ),
              if (_selectedImage != null)
                Image.file(File(_selectedImage!.path),
                    height: 200, fit: BoxFit.cover),

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
                children: _checklist.keys.map((task) {
                  return CheckboxListTile(
                    title: Text(task),
                    value: _checklist[task],
                    activeColor: Colors.pinkAccent,
                    onChanged: (val) {
                      setState(() {
                        _checklist[task] = val ?? false;
                      });
                    },
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
                  ElevatedButton(onPressed: _addProduct, child: const Text("Add"))
                ],
              ),
              Column(
                children: List.generate(_products.length, (index) {
                  return ListTile(
                    title: Text(_products[index]["name"]),
                    subtitle: Row(
                      children: List.generate(5, (starIndex) {
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: starIndex < _products[index]["rating"]
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          onPressed: () => _updateRating(index, starIndex + 1),
                        );
                      }),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeProduct(index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Journal Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Daily Journal",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pinkAccent)),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(hintText: "Write your notes..."),
                        maxLines: 3,
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
