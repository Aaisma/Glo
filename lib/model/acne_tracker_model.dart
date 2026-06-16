class AcneTrackerModel {
  final String date;
  final String severity;
  final List<String> checklist;
  final List<Map<String, dynamic>> products;
  final String note;
  final String imagePath;

  AcneTrackerModel({
    required this.date,
    required this.severity,
    required this.checklist,
    required this.products,
    required this.note,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      "date": date,
      "severity": severity,
      "checklist": checklist,
      "products": products,
      "note": note,
      "imagePath": imagePath,
    };
  }

  factory AcneTrackerModel.fromMap(String id, Map<String, dynamic> map) {
    return AcneTrackerModel(
      date: map["date"] ?? "",
      severity: map["severity"] ?? "Unknown",
      checklist: List<String>.from(map["checklist"] ?? []),
      products: List<Map<String, dynamic>>.from(map["products"] ?? []),
      note: map["note"] ?? "",
      imagePath: map["imagePath"] ?? "",
    );
  }
}