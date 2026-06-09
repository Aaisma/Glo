class WaterIntake {
  final String id;        // unique ID for each intake entry
  final double amount;    // amount of water in liters
  final DateTime date;    // when the water was consumed

  WaterIntake({
    required this.id,
    required this.amount,
    required this.date,
  });

  // Convert to Map (for saving later in Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
