import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationModel {
  String? id;
  String? name;
  String? type;
  String? dosage;
  String? schedule;
  DateTime? startDate;
  DateTime? endDate;

  // Prescription fields
  String? doctorName;
  String? instructions;
  DateTime? issuedDate;

  MedicationModel({
    this.id,
    this.name,
    this.type,
    this.dosage,
    this.schedule,
    this.startDate,
    this.endDate,
    this.doctorName,
    this.instructions,
    this.issuedDate,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> data, String docId) {
    return MedicationModel(
      id: docId,
      name: data['name'],
      type: data['type'],
      dosage: data['dosage'],
      schedule: data['schedule'],
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      doctorName: data['doctorName'],
      instructions: data['instructions'],
      issuedDate: data['issuedDate'] != null
          ? (data['issuedDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'dosage': dosage,
      'schedule': schedule,
      'startDate': startDate,
      'endDate': endDate,
      'doctorName': doctorName,
      'instructions': instructions,
      'issuedDate': issuedDate,
    };
  }
}
