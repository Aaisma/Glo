import 'package:cloud_firestore/cloud_firestore.dart';

class OvulationLogModel {
  final String id;
  final String userId;
  final DateTime date;
  final bool isFertileWindow;
  final bool isOvulationDay;
  final double? bbt;
  final String? sexDrive;
  final Map<String, bool> symptoms;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  OvulationLogModel({
    required this.id,
    required this.userId,
    required this.date,
    this.isFertileWindow = false,
    this.isOvulationDay = false,
    this.bbt,
    this.sexDrive,
    this.symptoms = const {},
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'isFertileWindow': isFertileWindow,
      'isOvulationDay': isOvulationDay,
      'bbt': bbt,
      'sexDrive': sexDrive,
      'symptoms': symptoms,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory OvulationLogModel.fromMap(Map<String, dynamic> map) {
    return OvulationLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      isFertileWindow: map['isFertileWindow'] ?? false,
      isOvulationDay: map['isOvulationDay'] ?? false,
      bbt: (map['bbt'] as num?)?.toDouble(),
      sexDrive: map['sexDrive'],
      symptoms: Map<String, bool>.from(map['symptoms'] ?? {}),
      note: map['note'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  OvulationLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    bool? isFertileWindow,
    bool? isOvulationDay,
    double? bbt,
    String? sexDrive,
    Map<String, bool>? symptoms,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OvulationLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      isFertileWindow: isFertileWindow ?? this.isFertileWindow,
      isOvulationDay: isOvulationDay ?? this.isOvulationDay,
      bbt: bbt ?? this.bbt,
      sexDrive: sexDrive ?? this.sexDrive,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
