import '../model/acne_tracker_model.dart';
import '../services/acne_service.dart';

class AcneViewModel {
  final AcneService service;

  String severity = "Moderate";
  List<String> checklist = [];
  List<Map<String, dynamic>> products = [];
  String note = "";
  String imagePath = "";

  AcneViewModel(this.service);

  void toggleChecklist(String item, bool value) {
    if (value) {
      if (!checklist.contains(item)) checklist.add(item);
    } else {
      checklist.remove(item);
    }
  }

  void addProduct(String name) {
    products.add({"name": name, "rating": 0});
  }

  void updateRating(int index, int rating) {
    products[index]["rating"] = rating;
  }

  void removeProduct(int index) {
    products.removeAt(index);
  }

  void updateNote(String value) {
    note = value;
  }

  void updateImage(String path) {
    imagePath = path;
  }

  Future<void> saveToday() async {
    final today = DateTime.now().toIso8601String().split("T")[0];

    await service.save(
      AcneTrackerModel(
        date: today,
        severity: severity,
        checklist: checklist,
        products: products,
        note: note,
        imagePath: imagePath,
      ),
    );
  }
}