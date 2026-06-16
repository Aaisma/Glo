class WaterTrackerModel {
  final String userId;
  final double intake;
  final double goal;
  final String date;

  // 🆕 ADD THIS
  final String note;

  WaterTrackerModel({
    required this.userId,
    required this.intake,
    required this.goal,
    required this.date,
    this.note = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "intake": intake,
      "goal": goal,
      "date": date,
      "note": note,
    };
  }

  factory WaterTrackerModel.fromMap(String id, Map<String, dynamic> map) {
    return WaterTrackerModel(
      userId: map["userId"] ?? "",
      intake: (map["intake"] ?? 0).toDouble(),
      goal: (map["goal"] ?? 2.5).toDouble(),
      date: map["date"] ?? "",
      note: map["note"] ?? "",
    );
  }
}