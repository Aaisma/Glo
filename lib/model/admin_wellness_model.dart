class AdminWellnessModel {
  final String? id;
  final String userName;
  final String wellnessType;
  final String notes;
  final double score;
  final DateTime createdAt;
  final List<Map<String, dynamic>> metrics;

  AdminWellnessModel({
    this.id,
    required this.userName,
    required this.wellnessType,
    required this.notes,
    required this.score,
    required this.createdAt,
    this.metrics = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "userName": userName,
      "wellnessType": wellnessType,
      "notes": notes,
      "score": score,
      "createdAt": createdAt.toIso8601String(),
      "metrics": metrics,
    };
  }

  factory AdminWellnessModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminWellnessModel(
      id: id,
      userName: map["userName"] ?? "",
      wellnessType: map["wellnessType"] ?? "",
      notes: map["notes"] ?? "",
      score: (map["score"] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map["createdAt"] ?? "") ?? DateTime.now(),
      metrics: List<Map<String, dynamic>>.from(map["metrics"] ?? []),
    );
  }
}
