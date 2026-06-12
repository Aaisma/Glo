class Medication {
  final String id;
  final String name;
  final String dosage;
  final DateTime startDate;
  final DateTime endDate;
  final String instructions;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
    required this.endDate,
    required this.instructions,
  });

  factory Medication.fromMap(Map<String, dynamic> data, String documentId) {
    return Medication(
      id: documentId,
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
      instructions: data['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'instructions': instructions,
    };
  }
}
