import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  String? id;
  String? userId;

  String? name;
  String? type;
  String? dosage;
  String? schedule;

  DateTime? startDate;
  DateTime? endDate;

  String? doctorName;
  String? instructions;
  DateTime? issuedDate;

  DateTime? createdAt;
  DateTime? updatedAt;

  MedicationModel({
    this.id,
    this.userId,
    this.name,
    this.type,
    this.dosage,
    this.schedule,
    this.startDate,
    this.endDate,
    this.doctorName,
    this.instructions,
    this.issuedDate,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicationModel.fromMap(
      Map<String, dynamic> data,
      String documentId,
      ) {
    return MedicationModel(
      id: documentId,
      userId: data['userId'] as String?,
      name: data['name'] as String?,
      type: data['type'] as String?,
      dosage: data['dosage'] as String?,
      schedule: data['schedule'] as String?,
      startDate: _toDateTime(data['startDate']),
      endDate: _toDateTime(data['endDate']),
      doctorName: data['doctorName'] as String?,
      instructions: data['instructions'] as String?,
      issuedDate: _toDateTime(data['issuedDate']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'dosage': dosage,
      'schedule': schedule,
      'startDate': startDate,
      'endDate': endDate,
      'doctorName': doctorName,
      'instructions': instructions,
      'issuedDate': issuedDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}