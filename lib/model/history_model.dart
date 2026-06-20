class HistoryModel {
  final String id;
  final String type;   // medication, visit, cycle, acne, mood, journal, system
  final String title;
  final String details;
  final DateTime date;

  HistoryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.details,
    required this.date,
  });

  factory HistoryModel.fromMap(String id, Map<String, dynamic> data) {
    return HistoryModel(
      id: id,
      type: data['type'] ?? 'unknown',
      title: data['title'] ?? '',
      details: data['details'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'details': details,
      'date': date.toIso8601String(),
    };
  }
}
