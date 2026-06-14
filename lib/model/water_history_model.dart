class WaterHistoryModel {
  final String date;
  final double intake;
  final double goal;

  WaterHistoryModel({
    required this.date,
    required this.intake,
    required this.goal,
  });

  double get percent => (intake / goal) * 100;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'intake': intake,
      'goal': goal,
      'percent': percent,
    };
  }

  factory WaterHistoryModel.fromMap(String date, Map<String, dynamic> map) {
    return WaterHistoryModel(
      date: date,
      intake: (map['intake'] ?? 0).toDouble(),
      goal: (map['goal'] ?? 2.5).toDouble(),
    );
  }
}