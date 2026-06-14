class WaterTrackerModel {
  final double currentIntake;
  final double goal;

  WaterTrackerModel({
    required this.currentIntake,
    required this.goal,
  });

  Map<String, dynamic> toMap() {
    return {
      "currentIntake": currentIntake,
      "goal": goal,
    };
  }

  factory WaterTrackerModel.fromMap(Map<String, dynamic> map) {
    return WaterTrackerModel(
      currentIntake: (map["currentIntake"] ?? 0).toDouble(),
      goal: (map["goal"] ?? 2.5).toDouble(),
    );
  }
}