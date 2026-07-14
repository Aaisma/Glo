class AcneTrackerModel {
  final String userId;
  final String date;
  final String severity;
  final List<String> checklist;
  final List<Map<String, dynamic>> products;
  final String note;
  final String imagePath;
  final String detectedType;
  final double detectedConfidence;

  AcneTrackerModel({
    required this.userId,
    required this.date,
    required this.severity,
    required this.checklist,
    required this.products,
    required this.note,
    required this.imagePath,
    this.detectedType = "",
    this.detectedConfidence = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "date": date,
      "severity": severity,
      "checklist": checklist,
      "products": products,
      "note": note,
      "imagePath": imagePath,
      "detectedType": detectedType,
      "detectedConfidence": detectedConfidence,
    };
  }

  factory AcneTrackerModel.fromMap(String id, Map<String, dynamic> map) {
    return AcneTrackerModel(
      userId: map["userId"] ?? "",
      date: map["date"] ?? "",
      severity: map["severity"] ?? "Unknown",
      checklist: List<String>.from(map["checklist"] ?? []),
      products: List<Map<String, dynamic>>.from(map["products"] ?? []),
      note: map["note"] ?? "",
      imagePath: map["imagePath"] ?? "",
      detectedType: map["detectedType"] ?? "",
      detectedConfidence: (map["detectedConfidence"] ?? 0.0).toDouble(),
    );
  }
}