class FollowUpReminder {
  final String id;
  final String visitId;
  final DateTime reminderDate;
  final String message;

  FollowUpReminder({
    required this.id,
    required this.visitId,
    required this.reminderDate,
    required this.message,
  });

  factory FollowUpReminder.fromMap(Map<String, dynamic> data, String documentId) {
    return FollowUpReminder(
      id: documentId,
      visitId: data['visitId'] ?? '',
      reminderDate: DateTime.parse(data['reminderDate']),
      message: data['message'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'reminderDate': reminderDate.toIso8601String(),
      'message': message,
    };
  }
}
