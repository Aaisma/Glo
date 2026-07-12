
class Journal {
  final String id;
  final String title;
  final String author;
  final String mood;
  final DateTime date;
  final bool isReported;

  Journal({
    required this.id,
    required this.title,
    required this.author,
    required this.mood,
    required this.date,
    this.isReported = false,
  });

  // Factory constructor for converting JSON response into a Dart Object
  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      author: json['author'] ?? 'Unknown',
      mood: json['mood'] ?? 'Neutral',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isReported: json['isReported'] ?? false,
    );
  }

  // Method to convert the object back to JSON for sending to a server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'mood': mood,
      'date': date.toIso8601String(),
      'isReported': isReported,
    };
  }

  // Helper to update specific fields easily
  Journal copyWith({
    String? title,
    String? mood,
    bool? isReported,
  }) {
    return Journal(
      id: id,
      title: title ?? this.title,
      author: author,
      mood: mood ?? this.mood,
      date: date,
      isReported: isReported ?? this.isReported,
    );
  }
}