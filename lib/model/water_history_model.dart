class WaterHistoryModel {
  final String date; // e.g. 2026-06-16
  final double intake;
  final double goal;
  final String note;

  WaterHistoryModel({
    required this.date,
    required this.intake,
    required this.goal,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      "date": date,
      "intake": intake,
      "goal": goal,
      "note": note,
    };
  }

  factory WaterHistoryModel.fromMap(String id, Map<String, dynamic> map) {
    return WaterHistoryModel(
      date: map["date"] ?? "",
      intake: (map["intake"] ?? 0).toDouble(),
      goal: (map["goal"] ?? 2.5).toDouble(),
      note: map["note"] ?? "",
    );
  }
}