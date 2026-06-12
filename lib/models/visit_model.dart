class Visit {
  final String id;
  final String doctorName;
  final DateTime date;
  final String notes;
  final bool followUpRequired;

  Visit({
    required this.id,
    required this.doctorName,
    required this.date,
    required this.notes,
    required this.followUpRequired,
  });

  factory Visit.fromMap(Map<String, dynamic> data, String documentId) {
    return Visit(
      id: documentId,
      doctorName: data['doctorName'] ?? '',
      date: DateTime.parse(data['date']),
      notes: data['notes'] ?? '',
      followUpRequired: data['followUpRequired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'notes': notes,
      'followUpRequired': followUpRequired,
    };
  }
}
