class WaterTrackerModel {
  final String userId;
  final double intake;
  final double goal;
  final String date;

  WaterTrackerModel({
    required this.userId,
    required this.intake,
    required this.goal,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "intake": intake,
      "goal": goal,
      "date": date,
    };
  }

  factory WaterTrackerModel.fromMap(Map<String, dynamic> map) {
    return WaterTrackerModel(
      userId: map["userId"] ?? "",
      intake: (map["intake"] ?? 0).toDouble(),
      goal: (map["goal"] ?? 2.5).toDouble(),
      date: map["date"] ?? "",
    );
  }
}