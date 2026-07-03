import 'package:cloud_firestore/cloud_firestore.dart';

class HealthModel {
  String? id;
  String? userId;

  // Skin Tip fields
  String? title;
  String? description;
  String? imageUrl;

  // Derma Visit fields
  String? concern;
  String? symptoms;
  String? diagnosis;
  String? treatment;
  String? prescription;
  String? doctorName;
  String? notes;
  DateTime? visitDate;
  DateTime? followUpDate;

  // Treatment Tracker fields
  String? treatmentName;
  int? progress; // percentage (0–100)
  DateTime? startDate;
  DateTime? endDate;

  DateTime? createdAt;
  DateTime? updatedAt;

  HealthModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.imageUrl,
    this.concern,
    this.symptoms,
    this.diagnosis,
    this.treatment,
    this.prescription,
    this.doctorName,
    this.notes,
    this.visitDate,
    this.followUpDate,
    this.treatmentName,
    this.progress,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory HealthModel.fromMap(Map<String, dynamic> data, String docId) {
    return HealthModel(
      id: docId,
      userId: data['userId'] as String?,

      // Skin Tip fields
      title: data['title'] as String?,
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,

      // Derma Visit fields
      concern: data['concern'] as String?,
      symptoms: data['symptoms'] as String?,
      diagnosis: data['diagnosis'] as String?,
      treatment: data['treatment'] as String?,
      prescription: data['prescription'] as String?,
      doctorName: data['doctorName'] as String?,
      notes: data['notes'] as String?,
      visitDate: _toDateTime(data['visitDate']),
      followUpDate: _toDateTime(data['followUpDate']),

      // Treatment Tracker fields
      treatmentName: data['treatmentName'] as String?,
      progress: data['progress'] as int?,
      startDate: _toDateTime(data['startDate']),
      endDate: _toDateTime(data['endDate']),

      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,

      // Skin Tip fields
      'title': title,
      'description': description,
      'imageUrl': imageUrl,

      // Derma Visit fields
      'concern': concern,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'doctorName': doctorName,
      'notes': notes,
      'visitDate': visitDate,
      'followUpDate': followUpDate,

      // Treatment Tracker fields
      'treatmentName': treatmentName,
      'progress': progress,
      'startDate': startDate,
      'endDate': endDate,

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