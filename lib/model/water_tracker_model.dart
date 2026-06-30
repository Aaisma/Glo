class WaterTrackerModel {
  final String userId;
  final String date;
  final double intake;
  final double goal;

  WaterTrackerModel({
    required this.userId,
    required this.date,
    required this.intake,
    required this.goal,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "date": date,
      "intake": intake,
      "goal": goal,
    };
  }

  factory WaterTrackerModel.fromMap(Map<String, dynamic> map) {
    return WaterTrackerModel(
      userId: map["userId"] ?? "",
      date: map["date"] ?? "",
      intake: (map["intake"] as num?)?.toDouble() ?? 0,
      goal: (map["goal"] as num?)?.toDouble() ?? 3.0,
    );
  }
}