class Prescription {
  final String id;
  final String medicationId;
  final String doctorName;
  final String instructions;
  final DateTime issuedDate;

  Prescription({
    required this.id,
    required this.medicationId,
    required this.doctorName,
    required this.instructions,
    required this.issuedDate,
  });

  factory Prescription.fromMap(Map<String, dynamic> data, String documentId) {
    return Prescription(
      id: documentId,
      medicationId: data['medicationId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      instructions: data['instructions'] ?? '',
      issuedDate: DateTime.parse(data['issuedDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'doctorName': doctorName,
      'instructions': instructions,
      'issuedDate': issuedDate.toIso8601String(),
    };
  }
}
