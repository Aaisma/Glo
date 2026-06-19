class JournalEntry {
  final String id;
  final String text;
  final String prompt;
  final Map<String, String> activities;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.text,
    required this.prompt,
    required this.activities,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'prompt': prompt,
    'activities': activities,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
    id: map['id'],
    text: map['text'],
    prompt: map['prompt'],
    activities: Map<String, String>.from(map['activities']),
    createdAt: DateTime.parse(map['createdAt']),
  );
}
