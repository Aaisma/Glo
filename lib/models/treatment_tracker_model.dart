class TreatmentTracker {
  final String id;
  final String treatmentName;
  final double progress; // 0.0 to 1.0
  final DateTime startDate;
  final DateTime endDate;

  TreatmentTracker({
    required this.id,
    required this.treatmentName,
    required this.progress,
    required this.startDate,
    required this.endDate,
  });

  factory TreatmentTracker.fromMap(Map<String, dynamic> data, String documentId) {
    return TreatmentTracker(
      id: documentId,
      treatmentName: data['treatmentName'] ?? '',
      progress: (data['progress'] ?? 0).toDouble(),
      startDate: DateTime.parse(data['startDate']),
      endDate: DateTime.parse(data['endDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'treatmentName': treatmentName,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
