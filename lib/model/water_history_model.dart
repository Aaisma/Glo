class WaterHistoryModel {
  final String date;
  final double intake;
  final double goal;

  WaterHistoryModel({
    required this.date,
    required this.intake,
    required this.goal,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'intake': intake,
      'goal': goal,
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