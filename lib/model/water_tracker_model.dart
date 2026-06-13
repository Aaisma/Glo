class WaterTrackerModel {
  final double currentIntake;
  final double goal;

  WaterTrackerModel({
    required this.currentIntake,
    required this.goal,
  });

  // Optional: helps when saving/loading later from Firebase
  Map<String, dynamic> toMap() {
    return {
      'currentIntake': currentIntake,
      'goal': goal,
    };
  }

  // Optional: helps when reading from Firebase later
  factory WaterTrackerModel.fromMap(Map<String, dynamic> map) {
    return WaterTrackerModel(
      currentIntake: (map['currentIntake'] ?? 0).toDouble(),
      goal: (map['goal'] ?? 2.5).toDouble(),
    );
  }
}