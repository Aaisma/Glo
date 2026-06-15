import 'package:cloud_firestore/cloud_firestore.dart';

class VisitModel {
  String? id;
  String? doctorName;
  DateTime? visitDate;
  String? notes;
  List<String>? medicationIds; // link to medications
  bool followUpRequired;
  DateTime? followUpDate;
  String? followUpMessage;

  VisitModel({
    this.id,
    this.doctorName,
    this.visitDate,
    this.notes,
    this.medicationIds,
    this.followUpRequired = false,
    this.followUpDate,
    this.followUpMessage,
  });

  factory VisitModel.fromMap(Map<String, dynamic> data, String docId) {
    return VisitModel(
      id: docId,
      doctorName: data['doctorName'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      notes: data['notes'],
      medicationIds: List<String>.from(data['medicationIds'] ?? []),
      followUpRequired: data['followUpRequired'] ?? false,
      followUpDate: data['followUpDate'] != null
          ? (data['followUpDate'] as Timestamp).toDate()
          : null,
      followUpMessage: data['followUpMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorName': doctorName,
      'visitDate': visitDate,
      'notes': notes,
      'medicationIds': medicationIds,
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate,
      'followUpMessage': followUpMessage,
    };
  }
}
