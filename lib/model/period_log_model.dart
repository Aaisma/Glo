import 'package:cloud_firestore/cloud_firestore.dart';

class PeriodLogModel {
  final String id;
  final String userId;
  final DateTime date;
  final bool isPeriodDay;
  final double? bbt;
  final String? flow;
  final Map<String, bool> symptoms;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PeriodLogModel({
    required this.id,
    required this.userId,
    required this.date,
    this.isPeriodDay = false,
    this.bbt,
    this.flow,
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
      'isPeriodDay': isPeriodDay,
      'bbt': bbt,
      'flow': flow,
      'symptoms': symptoms,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory PeriodLogModel.fromMap(Map<String, dynamic> map) {
    return PeriodLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date']),
      isPeriodDay: map['isPeriodDay'] ?? false,
      bbt: (map['bbt'] as num?)?.toDouble(),
      flow: map['flow'],
      symptoms: Map<String, bool>.from(map['symptoms'] ?? {}),
      note: map['note'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  PeriodLogModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    bool? isPeriodDay,
    double? bbt,
    String? flow,
    Map<String, bool>? symptoms,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PeriodLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      isPeriodDay: isPeriodDay ?? this.isPeriodDay,
      bbt: bbt ?? this.bbt,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
