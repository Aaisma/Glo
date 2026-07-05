class FeedbackModel {
  final String category;
  final String type;
  final String message;
  final int ratingIndex;
  final DateTime timestamp;

  FeedbackModel({
    required this.category,
    required this.type,
    required this.message,
    required this.ratingIndex,
    required this.timestamp,
  });

  /// Convert to Firestore‑friendly JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'type': type,
      'message': message,
      'rating_index': ratingIndex,
      // Store as Firestore Timestamp for easier querying
      'timestamp': timestamp,
    };
  }

  /// Create model from Firestore JSON
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      category: json['category'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      ratingIndex: json['rating_index'] ?? -1,
      timestamp: _parseTimestamp(json['timestamp']),
    );
  }

  /// Helper to handle both String and Firestore Timestamp
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    // Firestore Timestamp type
    if (value is dynamic && value.toDate != null) {
      return value.toDate();
    }
    return DateTime.now();
  }
}
