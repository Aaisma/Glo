import 'package:flutter/material.dart';
import 'dart:io';
import '../model/acne_tracker_model.dart';
import '../repo/acne_repo.dart';
import '../services/cloudinary_service.dart';
import '../services/acne_classifier_service.dart';

class AcneTrackerViewModel extends ChangeNotifier {
  final AcneRepo _repo;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AcneClassifierService _classifier = AcneClassifierService();

  AcneTrackerViewModel(this._repo);

  bool isLoading = false;
  String? errorMessage;
  bool modelReady = false;

  List<AcneTrackerModel> history = [];

  String severity = "Unknown";
  List<String> checklist = [];
  List<Map<String, dynamic>> products = [];
  String note = "";
  String imagePath = "";

  String? detectedType;
  double? detectedConfidence;

  String _todayDate() => DateTime.now().toIso8601String().split("T")[0];

  Future<void> initClassifier() async {
    try {
      await _classifier.loadModel();
      modelReady = true;
    } catch (e) {
      errorMessage = "Failed to load detection model: $e";
    }
  }

  Future<void> loadToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = await _repo.getEntry(userId, _todayDate());
      if (entry != null) {
        severity = entry.severity;
        checklist = entry.checklist;
        products = entry.products;
        note = entry.note;
        imagePath = entry.imagePath;
      }
    } catch (e) {
      errorMessage = "Failed to load today's entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      history = await _repo.getAllEntries(userId);
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to load history: $e";
      notifyListeners();
    }
  }

  void setSeverity(String value) {
    severity = value;
    notifyListeners();
  }

  void toggleChecklistItem(String item) {
    if (checklist.contains(item)) {
      checklist.remove(item);
    } else {
      checklist.add(item);
    }
    notifyListeners();
  }

  void addProduct(String name) {
    products.add({"name": name, "rating": 0});
    notifyListeners();
  }

  void removeProduct(int index) {
    products.removeAt(index);
    notifyListeners();
  }

  void updateProductRating(int index, int rating) {
    products[index]["rating"] = rating;
    notifyListeners();
  }

  void updateNote(String value) {
    note = value;
    notifyListeners();
  }

  Future<void> uploadPhoto(File file) async {
    isLoading = true;
    notifyListeners();

    try {
      if (modelReady) {
        try {
          final result = await _classifier.classify(file);
          detectedType = result["label"];
          detectedConfidence = result["confidence"];
        } catch (e) {
          errorMessage = "Detection failed: $e";
        }
      }

      final url = await _cloudinaryService.uploadImage(file);
      if (url != null) {
        imagePath = url;
      } else {
        errorMessage = "Photo upload failed";
      }
    } catch (e) {
      errorMessage = "Photo upload failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveToday(String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final entry = AcneTrackerModel(
        userId: userId,
        date: _todayDate(),
        severity: severity,
        checklist: checklist,
        products: products,
        note: note,
        imagePath: imagePath,
      );
      await _repo.saveEntry(entry);
    } catch (e) {
      errorMessage = "Failed to save entry: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}