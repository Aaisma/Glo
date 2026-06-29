class MealEntryModel {
  final String userId;
  final String date;
  final List<Map<String, dynamic>> meals; // each: {type, items: List<String>, tags: List<String>}
  final String note;

  MealEntryModel({
    required this.userId,
    required this.date,
    required this.meals,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "date": date,
      "meals": meals,
      "note": note,
    };
  }

  factory MealEntryModel.fromMap(String id, Map<String, dynamic> map) {
    return MealEntryModel(
      userId: map["userId"] ?? "",
      date: map["date"] ?? "",
      meals: List<Map<String, dynamic>>.from(
        (map["meals"] ?? []).map((m) => Map<String, dynamic>.from(m)),
      ),
      note: map["note"] ?? "",
    );
  }
}