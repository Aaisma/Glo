import 'package:cloud_firestore/cloud_firestore.dart';

class HealthModel {
  String? id;

  // Skin Tip fields
  String? title;
  String? description;
  String? imageUrl;

  // Treatment Tracker fields
  String? treatmentName;
  int? progress; // percentage (0–100)
  DateTime? startDate;
  DateTime? endDate;

  HealthModel({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.treatmentName,
    this.progress,
    this.startDate,
    this.endDate,
  });

  factory HealthModel.fromMap(Map<String, dynamic> data, String docId) {
    return HealthModel(
      id: docId,
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      treatmentName: data['treatmentName'],
      progress: data['progress'],
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'treatmentName': treatmentName,
      'progress': progress,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
